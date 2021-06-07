-- call this to see if service has specified state
-- hunter.SERVICE_STOPPED 1
-- hunter.SERVICE_START_PENDING 2
-- hunter.SERVICE_STOP_PENDING 3
-- hunter.SERVICE_RUNNING 4
-- hunter.SERVICE_CONTINUE_PENDING 5
-- hunter.SERVICE_PAUSE_PENDING 6
-- hunter.SERVICE_PAUSED 7
-- service states are grouped together
function check_service_state(service_state, desired_state)
    if desired_state == "any" then
        return true
    elseif desired_state == "stopped" then
        return service_state == 1 or service_state == 3
    elseif desired_state == "running" then
        return service_state == 2 or service_state == 4 or service_state == 5
    elseif desired_state == "paused" then
        return service_state == 6 or service_state == 7
    else
        return false
    end
end

-- call this to do wildcard matching of service names
function find_service_match(match_string)
    local found_services = {}
    local bresult
    local not_operation

    function service_callback(service_info)
        bresult, not_operation = item_compare(match_string, service_info.service_name)
        if bresult then
            table.insert(found_services, service_info)
        end
    end

    hunter.log("Enumerating all Win32 Services on the System in any State", hunter.LOG_LEVEL_DEBUG)
    local num_svcs = hunter.enum_services(hunter.SERVICE_WIN32, hunter.SERVICE_STATE_ALL, service_callback)
    hunter.log("Finished enumeration. Saw "..num_svcs.." services ", hunter.LOG_LEVEL_DEBUG)

    return found_services, not_operation
end

-- Find a service similar to the service_name_match_string with a given state
function find_service_with_state(test_id, service_name_match_string, state)
    local test_result = {id = 0, result = false, details = {}}
    local matched_services, not_operation = find_service_match(service_name_match_string)
    local any_matches = tablelength(matched_services) > 0

    if any_matches and not_operation == false then

        for _,result in ipairs(matched_services) do
            table.insert(test_result.details,{type="Service",attributes=result})
        end

        -- check each matched service's state
        for i, matched_service in ipairs(matched_services) do
            local service_state = check_service_state(matched_service.service_state, state)

            if service_state == true then
                test_result.result = true
                break
            end
        end
    elseif any_matches and not_operation then
        -- Return true since there are matches
        test_result.result = true
        for _,result in ipairs(matched_services) do
            table.insert(test_result.details,{type="Service",attributes=result})
        end

    elseif any_matches == false and not_operation == false then
        --  Return false, as no matches exist
        test_result.result = false
    elseif any_matches == false and not_operation then
        -- Return true since the service exists
        test_result.result = true
    end

    test_result.id = test_id
    return test_result
end

-- Handle a serach_str with multipe csv values
function find_services_with_state(test_id, search_str, state)
  local final_test_result = {id=test_id,result=false,details={}}

  local split_search_strs = split(search_strs, "[^,%s]+")

  for i, search_str in ipairs(split_search_strs) do
    local test_result = find_service_with_state(test_id, search_str, state)

    if test_result.result == true then
      for _,result in ipairs(test_result.details) do

        local formatted_test_result={type="Service",attributes=result}

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
