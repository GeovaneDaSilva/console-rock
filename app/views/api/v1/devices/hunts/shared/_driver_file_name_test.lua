local driver_list = hunter.get_device_drivers()

function find_driver_file_name(test_id, search_str)
  local test_result = {id=test_id,result=false,details={}}
  local found_entries,not_operation = find_entry_in_driver_list(driver_list,search_str)
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
function find_driver_file_names(test_id, search_strs)
  local final_test_result = {id=test_id,result=false,details={}}

  local split_search_strs = split(search_strs, "[^,%s]+")

  for i, search_str in ipairs(split_search_strs) do
    local test_result = find_driver_file_name(test_id, search_str)

    if test_result.result == true then
      for _,result in ipairs(test_result.details) do

        local formatted_test_result={type="Driver",attributes=result}

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
