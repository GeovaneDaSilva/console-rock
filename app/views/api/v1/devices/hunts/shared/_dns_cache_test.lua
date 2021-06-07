
function find_entry_in_dns_cache(dns_cache,entry_to_find)
  local found_entries = {}
  local not_operation = false
  local bresult = false

  hunter.log("Scanning DNS cache list for match for "..tostring(entry_to_find),hunter.LOG_LEVEL_DEBUG)
  for _,cache_entry in ipairs(dns_cache) do
    if type(cache_entry)=='table' then
      bresult,not_operation=item_compare(entry_to_find,cache_entry.dns_entry_name)
      if bresult then
        hunter.log("dns_entry_name="..tostring(cache_entry.dns_entry_name),hunter.LOG_LEVEL_INFO)
        hunter.log("dns_entry_type="..tostring(cache_entry.dns_entry_type),hunter.LOG_LEVEL_INFO)
        local query_result = hunter.dns_query(cache_entry.dns_entry_name,cache_entry.dns_entry_type)

        for k,v in pairs(query_result) do
          cache_entry[k] = v
        end

        cache_entry.schema = { order={ "dns_entry_name", "ttl", "host", "ipv4_address" } }

        hunter.log("Found DNS Cache entry match : "..tostring(cache_entry.dns_entry_name),hunter.LOG_LEVEL_TRACE)
        table.insert(found_entries,cache_entry)
      end
    end
  end

  return found_entries, not_operation
end

local dns_cache = hunter.get_dns_cache_entries()

function find_dns_cache(test_id, search_str)
  local test_result = {id=test_id,result=false,details={}}
  local found_entries,not_operation = find_entry_in_dns_cache(dns_cache,search_str)
  if not_operation and tablelength(found_entries)>0 then
    -- this is a not exist operation that failed
    hunter.log("Not operation failed",hunter.LOG_LEVEL_TRACE)
    test_result.result=false
  elseif not_operation and tablelength(found_entries)==0 then
    -- this is a not operation that passed
    hunter.log("Not operation passed",hunter.LOG_LEVEL_TRACE)
    test_result.result=true
  elseif tablelength(found_entries)>0 and not_operation==false then
    -- this is a regular match (exists) operation that passed
    hunter.log("Match operation passed",hunter.LOG_LEVEL_TRACE)
    test_result.result=true
  else
    hunter.log("Match operation failed",hunter.LOG_LEVEL_TRACE)
  end
  if agent_options.verbosity<=hunter.LOG_LEVEL_DEBUG then
    test_result.search=search_str
  end

  if tablelength(found_entries)>0 then
    test_result.details=found_entries
  end

  return test_result
end

-- Handle a serach_str with multipe csv values
function find_dns_caches(test_id, search_strs)
  local final_test_result = {id=test_id,result=false,details={}}

  local split_search_strs = split(search_strs, "[^,%s]+")

  for i, search_str in ipairs(split_search_strs) do
    local test_result = find_dns_cache(test_id, search_str)

    if test_result.result == true then

      for _,result in ipairs(test_result.details) do

        local formatted_test_result={type="DNS",attributes=result}

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
