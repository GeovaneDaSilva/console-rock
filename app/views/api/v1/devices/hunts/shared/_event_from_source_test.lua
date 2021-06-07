function match_event_source(log_name, event_source)
    local found_events = {}
    local bresult = false
    local not_operation = false

    local function log_callback(event_info)
        bresult, not_operation = item_compare(event_source, event_info.source_name)
        if bresult then
            table.insert(found_events, event_info)
        end
    end

    hunter.read_event_channel(log_name,nil,log_callback)

    return found_events, not_operation
end

-- Find a events in category with messages matching text
function find_event_from_source_with_message(test_id, event_log_name, source_name, message_match_str)
    local test_result = {id = 0, result = false, details = {}}
    local matched_events_from_source, not_operation = match_event_source(event_log_name, source_name)

    if tablelength(matched_events_from_source) > 0 then
        local matched_events_with_message, not_operation = match_event_message_in_events(matched_events_from_source, message_match_str)
        local any_matches = tablelength(matched_events_with_message) > 0

        if any_matches and not_operation == false then
            -- Results are expected, and found, return true
            test_result.result = true
            for _,result in ipairs(matched_events_with_message) do
                table.insert(test_result.details,{type="EventLog",attributes=result})
            end
        elseif any_matches and not_operation then
            -- Results are not expected, but they were found, return true
            test_result.result = true
            for _,result in ipairs(matched_events_with_message) do
                table.insert(test_result.details,{type="EventLog",attributes=result})
            end
        elseif any_matches == false and not_operation then
            -- Results are not expected, and they were not found, return false
            test_result.result = false
        elseif any_matches == false and not_operation == false then
            -- Results are expected, but they were not found, return true
            test_result.result = true
        end
    else
        -- No events in for the category
        test_result.result = false
    end

    test_result.id = test_id
    return test_result
end

-- Handle a message_match_str with multipe csv values

function find_event_from_source_with_messages(test_id, event_log_name, source_name, message_match_str)
  local final_test_result = {id=test_id,result=false,details={}}

  local split_message_match_strs = split(message_match_str, "[^,%s]+")

  for i, message_match_str in ipairs(split_message_match_strs) do
    local test_result = find_event_from_source_with_message(test_id, event_log_name, source_name, message_match_str)

    if test_result.result == true then
       for _,result in ipairs(test_result.details) do

        local formatted_test_result={type="EventLog",attributes=result}

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
