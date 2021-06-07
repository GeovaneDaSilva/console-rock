function search_for_file(file_to_find)
    -- figure out if we are searching for a hash, or a filename
    -- also is there a starting directory?

    local found_files = {}
    local match_md5 = false
    local match_file_name = true -- default
    local match_sha1 = false
    local match_sha2 = false
    local not_operation = false
    local drive_to_scan
    local file_name_to_scan


    if file_to_find:find("%%") then
        file_to_find = hunter.expand_env_string(file_to_find)
    end

    local patterns = {md5 = [[\b[A-Fa-f0-9]{32}\b]], sha1 = [[\b[A-Fa-f0-9]{40}\b]], sha2 = [[\b[A-Fa-f0-9]{64}\b]]}

    for key, pattern in pairs(patterns) do
        matches, num_matches = hunter.regex_match(file_to_find, pattern)
        if num_matches > 0 then
            if key == "md5" then
                match_md5 = true
                match_file_name = false
                break
            elseif key == "sha1" then
                match_sha1 = true
                match_file_name = false
                break
            elseif key == "sha2" then
                match_sha2 = true
                match_file_name = false
                break
            end
        end
    end

    hunter.log("match_file_name = "..tostring(match_file_name) .. " match_md5 = "..tostring(match_md5) .. " match_sha1 = "..tostring(match_sha1) .. " match_sha2 = "..tostring(match_sha2), hunter.LOG_LEVEL_TRACE)

    local function find_file_usn_journal(file_to_find,found_files)

        local file_found = false

        local function fast_query_callback(file_info)

            hunter.log("got fast_query_callback for : "..tostring(file_info.file_path),hunter.LOG_LEVEL_DEBUG)
            local dir_name,file_name = hunter.split_path(file_info.file_path)
            local bresult, not_operation = item_compare(file_to_find, file_name,false) -- case insensitive
            if bresult then
                hunter.log("fast_query_callback item_compare returned  : "..tostring(bresult),hunter.LOG_LEVEL_DEBUG)
                file_info = get_detailed_file_info(file_info.file_path)
                table.insert(found_files, file_info)
                file_found = true
            end

        end


        local disk_types = hunter.get_available_disks()
        for _,disk in ipairs(disk_types) do
            if disk.drive_type==hunter.DRIVE_FIXED then
                hunter.log("Searching drive "..tostring(disk.drive_letter),hunter.LOG_LEVEL_DEBUG)
                hunter.fast_query_file(disk.drive_letter,file_to_find,fast_query_callback)
            end
        end

        return file_found

    end

    local function check_hash_db(drive_to_scan, file_name_to_scan)

        local found_files = {}
        local not_operation = false

        if hash_db then

            hunter.log("checking hash db for "..tostring(drive_to_scan)..tostring(file_name_to_scan), hunter.LOG_LEVEL_TRACE)
            local db_results
            if match_file_name then
                if drive_to_scan:len()>0 then
                    hunter.log("Calling query_file_path - "..tostring(drive_to_scan) .. " "..tostring(file_name_to_scan), hunter.LOG_LEVEL_TRACE)
                    db_results = hash_db.query_file_path(drive_to_scan..file_name_to_scan)
                    if type(db_results) == 'table' then
                        for _, record in ipairs(db_results) do
                            bresult, not_operation = item_compare(file_to_find, record.full_path)
                            if bresult then
                                table.insert(found_files, record)
                            end
                        end
                    end
                else
                    hunter.log("Calling query_file_name - "..tostring(file_to_find), hunter.LOG_LEVEL_TRACE)
                    db_results = hash_db.query_file_name(file_to_find)
                    if db_results.num_rows==0 and hunter.fast_query_file~=nil then
                        local result = find_file_usn_journal(file_to_find,found_files)
                    else
                        for _, record in ipairs(db_results) do
                            bresult, not_operation = item_compare(file_to_find, record.file_name,false) -- case insensitive
                            if bresult then
                                table.insert(found_files, record)
                            end
                        end
                    end
                end
            elseif match_md5 then
                local hash_func = hash_db.query_md5_files or hash_db.query_md5
                hunter.log("Caling query_md5 - "..tostring(file_name_to_scan), hunter.LOG_LEVEL_TRACE)
                db_results = hash_func(file_name_to_scan)
                if type(db_results) == 'table' then
                    for _, record in ipairs(db_results) do
                        bresult, not_operation = item_compare(file_to_find, record.md5)
                        if bresult then
                            table.insert(found_files, record)
                        end
                    end
                end
            elseif match_sha1 then
                local hash_func = hash_db.query_sha1_files or hash_db.query_sha1
                hunter.log("Caling query_sha1 - "..tostring(file_name_to_scan), hunter.LOG_LEVEL_TRACE)
                db_results = hash_func(file_name_to_scan)
                if type(db_results) == 'table' then
                    for _, record in ipairs(db_results) do
                        bresult, not_operation = item_compare(file_to_find, record.sha1)
                        if bresult then
                            table.insert(found_files, record)
                        end
                    end
                end
            elseif match_sha2 then
                local hash_func = hash_db.query_sha2_files or hash_db.query_sha2
                hunter.log("Caling query_sha2 - "..tostring(file_name_to_scan), hunter.LOG_LEVEL_TRACE)
                db_results = hash_func(file_name_to_scan)
                if type(db_results) == 'table' then
                    for _, record in ipairs(db_results) do
                        bresult, not_operation = item_compare(file_to_find, record.sha2)
                        if bresult then
                            table.insert(found_files, record)
                        end
                    end
                end
            end
        end
        return found_files, not_operation
    end


    local parsed_file_pattern = parse_search_pattern(file_to_find)
    drive_to_scan, file_name_to_scan = hunter.split_path(parsed_file_pattern, false)

    found_files, not_operation = check_hash_db(drive_to_scan, file_name_to_scan)
    if tablelength(found_files) > 0 then
        hunter.log("Found hits in hash db. ", hunter.LOG_LEVEL_DEBUG)
        return found_files, not_operation
    end


    return found_files, not_operation

end

function find_file(test_id, search_str)
    local test_result = {id = 0, result = false, details = {}}

    hunter.log("Calling search_for_file with search_str : "..tostring(search_str), hunter.LOG_LEVEL_TRACE)

    local found_files, not_operation = search_for_file(search_str)
    if not_operation and tablelength(found_files) > 0 then
        -- this is a not exist operation that failed
        hunter.log("Not operation failed", hunter.LOG_LEVEL_TRACE)
        test_result.result = false
    elseif not_operation and tablelength(found_files) == 0 then
        -- this is a not operation that passed
        hunter.log("Not operation passed", hunter.LOG_LEVEL_TRACE)
        test_result.result = true
    elseif tablelength(found_files) > 0 and not_operation == false then
        -- this is a regular match (exists) operation that passed
        hunter.log("Match operation passed", hunter.LOG_LEVEL_TRACE)
        test_result.result = true
    else
        hunter.log("Match operation failed", hunter.LOG_LEVEL_TRACE)
    end
    if agent_options.verbosity <= hunter.LOG_LEVEL_DEBUG then
        test_result.search = search_str
    end
    if tablelength(found_files) > 0 then
        test_result.details = found_files
    end
    test_result.id = test_id

    return test_result
end

hash_db = new_hash_db()
if hash_db == nil then
    hunter.log("Error creating hashdb instance", hunter.LOG_LEVEL_ERROR)
    return
end

if hash_db.open_hash_db then -- TODO delete this block once lmdb is fully deployed
    hunter.log("Calling open_hash_db", hunter.LOG_LEVEL_INFO)
    local bresult = hash_db.open_hash_db()
    if not bresult then
        hunter.log("Error opening hash db", hunter.LOG_LEVEL_ERROR)
        return
    end
end

-- Handle a search_str with multipe csv values
function find_files(test_id, search_str)
  local final_test_result = {id=test_id,result=false,details={}}

  local split_search_strs = string.split(search_str, ",")

  for i, search_str in ipairs(split_search_strs) do
    search_str = string.trim(search_str)
    local test_result = find_file(test_id, search_str)

    if test_result.result == true then
      for _,result in ipairs(test_result.details) do

        local formatted_test_result={type="File",attributes=result}

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
