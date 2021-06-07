function get_connection_process_info(conn)
    if type(conn) ~= "table" then
        hunter.log("Invalid connection table passed to get_connection_process_info", hunter.LOG_LEVEL_ERROR)
        return tcp_table
    end

    if conn.pid then
        local image_path = hunter.get_process_file_name(conn.pid)
        if image_path ~= nil then
            conn.image_path = image_path
            local cmd_line = hunter.wmi_query("root\\cimv2", "Select CommandLine, CreationDate From Win32_Process where ProcessId="..tostring(math.floor(conn.pid)))
            if type(cmd_line) == "table" then
                conn.cmd_line = tostring(cmd_line[0].CommandLine)
                if cmd_line[0].CreationDate ~= nil then
                    conn.created = hunter.wmi_date_to_time_t(cmd_line[0].CreationDate)
                end
            end
            if string.find(image_path, "\\Device\\") then
                conn.dos_path = hunter.convert_volume_path(image_path)
                local md5,sha1,sha2=hunter.hash_file_common(conn.dos_path)
                conn.md5=md5
                conn.sha1=sha1
                conn.sha2=sha2
                local version_info  = hunter.get_file_version_info(conn.dos_path)
                if type(version_info) == "table" then
                    for name,value in pairs(version_info) do
                        conn[name]=value
                    end
                end
                conn.file_owner = hunter.get_file_owner(conn.dos_path)
            end
        end
        local process_owner = hunter.get_process_owner(conn.pid)
        if process_owner then
            conn.owner=process_owner
        end
    end
    return conn
end

function find_connection_in_connections(active_connections, connection_to_find)
    local found_connections = {}
    local not_operation = false
    local bresult = false

    hunter.log("Scanning connection list for match for "..tostring(connection_to_find), hunter.LOG_LEVEL_DEBUG)
    local parsed_connection = parse_search_pattern(connection_to_find)
    -- hunter.log("parsed_connection : "..tostring(parsed_connection),hunter.LOG_LEVEL_DEBUG)

    for _, connection in ipairs(active_connections) do
        local ip_pattern = [[^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$]]
        local ipv6_pattern = [[^((([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}:[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){5}:([0-9A-Fa-f]{1,4}:)?[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){4}:([0-9A-Fa-f]{1,4}:){0,2}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){3}:([0-9A-Fa-f]{1,4}:){0,3}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){2}:([0-9A-Fa-f]{1,4}:){0,4}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){6}((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|(([0-9A-Fa-f]{1,4}:){0,5}:((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|(::([0-9A-Fa-f]{1,4}:){0,5}((\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b)\.){3}(\b((25[0-5])|(1\d{2})|(2[0-4]\d)|(\d{1,2}))\b))|([0-9A-Fa-f]{1,4}::([0-9A-Fa-f]{1,4}:){0,5}[0-9A-Fa-f]{1,4})|(::([0-9A-Fa-f]{1,4}:){0,6}[0-9A-Fa-f]{1,4})|(([0-9A-Fa-f]{1,4}:){1,7}:))$]]
        local fqdn_pattern = [[(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)]]

        local matches, num_matches = hunter.regex_match(parsed_connection, ip_pattern)
        if num_matches > 0 then
            -- this is an ip address
            bresult, not_operation = item_compare(connection_to_find, connection.remote_address)
            if bresult then
                hunter.log("Found connection match : "..tostring(connection.remote_address), hunter.LOG_LEVEL_TRACE)
                table.insert(found_connections, connection)
            end
        else
            -- hunter.log("checking : "..tostring(parsed_connection),hunter.LOG_LEVEL_DEBUG)
            local matches, num_matches = hunter.regex_match(parsed_connection, fqdn_pattern)
            if num_matches > 0 then
                -- this is a hostname
                if not connection.dns_name and not connection.lookup_attempt then
                    local dns_name = hunter.get_host_from_ipv4(connection.remote_address)
                    if dns_name ~= nil then
                        connection.dns_name = dns_name
                    else
                        hunter.log("Could not resolve hostname for "..tostring(connection.remote_address), hunter.LOG_LEVEL_WARNING)
                    end
                    connection.lookup_attempt = hunter.timestamp()
                end
                if connection.dns_name then
                    bresult, not_operation = item_compare(connection_to_find, connection.dns_name)
                    if bresult then
                        hunter.log("Found connection match : "..tostring(dns_name), hunter.LOG_LEVEL_TRACE)
                        table.insert(found_connections, connection)
                    end
                end
            else
                local matches, num_matches = hunter.regex_match(parsed_connection, ipv6_pattern)
                if num_matches > 0 then
                    hunter.log("Search pattern "..tostring(connection_to_find) .. " is an IPV6 address. Add support.", hunter.LOG_LEVEL_DEBUG)
                else
                    hunter.log("Search pattern "..tostring(connection_to_find) .. " is neither a valid ip nor a valid fqdn", hunter.LOG_LEVEL_ERROR)

                end
            end
        end

    end
    hunter.log("find_connection returning "..tostring(found_connections) .. " "..tostring(tablelength(found_connections)) .. " not_operation = "..tostring(not_operation), hunter.LOG_LEVEL_TRACE)

    return found_connections, not_operation, active_connections
end

hunter.log("Collecting active network connections", hunter.LOG_LEVEL_DEBUG)
local active_connections = hunter.get_tcp_connections()

function find_network_connection(test_id, search_str)
    local test_result = {id = 0, result = false, details = {}}
    local found_connections, not_operation, active_connections = find_connection_in_connections(active_connections, search_str)
    if not_operation and tablelength(found_connections) > 0 then
        -- this is a not exist operation that failed
        hunter.log("Not operation failed", hunter.LOG_LEVEL_TRACE)
        test_result.result = false
    elseif not_operation and tablelength(found_connections) == 0 then
        -- this is a not operation that passed
        hunter.log("Not operation passed", hunter.LOG_LEVEL_TRACE)
        test_result.result = true
    elseif tablelength(found_connections) > 0 and not_operation == false then
        -- this is a regular match (exists) operation that passed
        hunter.log("Match operation passed", hunter.LOG_LEVEL_TRACE)
        test_result.result = true
    else
        hunter.log("Match operation failed", hunter.LOG_LEVEL_TRACE)
    end
    if agent_options.verbosity <= hunter.LOG_LEVEL_DEBUG then
        test_result.search = search_str
    end

    if tablelength(found_connections) > 0 then
        for _, connection in ipairs(found_connections) do
            table.insert(test_result.details, get_connection_process_info(connection))
        end
    end

    test_result.id = test_id
    return test_result
end

-- Handle a serach_str with multipe csv values
function find_network_connections(test_id, search_strs)
  local final_test_result = {id=test_id,result=false,details={}}

  local split_search_strs = split(search_strs, "[^,%s]+")

  for i, search_str in ipairs(split_search_strs) do
    local test_result = find_network_connection(test_id, search_str)

    if test_result.result == true then
      for _,result in ipairs(test_result.details) do

        local formatted_test_result={type="Network",attributes=result}

        table.insert(final_test_result.details, formatted_test_result)

      end

    end
    hunter.wait(wait_time)
  end

  if tablelength(final_test_result.details)>0 then
    final_test_result.result = true
  end

  return final_test_result
end
