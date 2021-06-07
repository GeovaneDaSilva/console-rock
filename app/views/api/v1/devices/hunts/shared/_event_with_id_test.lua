function match_event_id(log_name, event_id)
    local found_events = {}
    local bresult = false
    local not_operation = false

    local function log_callback(event_info)
        if event_id == event_info.event_id then
            table.insert(found_events, event_info)
        end
    end

    hunter.read_event_channel(log_name,nil, log_callback)

    return found_events, not_operation
end

-- Find a events in wth id with messages matching text
function find_event_with_id_with_message(test_id, event_log_name, event_id, message_match_str)
    local test_result = {id = 0, result = false, details = {}}
    local matched_events_with_id, not_operation = match_event_id(event_log_name, event_id)

    if tablelength(matched_events_with_id) > 0 then
        local matched_events_with_message, not_operation = match_event_message_in_events(matched_events_with_id, message_match_str)
        local any_matches = tablelength(matched_events_with_message) > 0
        if any_matches==true then
            test_result.result = true
            for _,result in ipairs(matched_events_with_message) do
                table.insert(test_result.details,{type="EventLog",attributes=result})
            end
        end

    end

    test_result.id = test_id
    return test_result
end

-- Find a events with id with messages matching text
-- THIS FUNCTION DOESNT MAKE SENSE AND DOESNT APPEAR TO BE CALLED ANYWHERE

function find_event_with_id_with_messages(test_id, event_log_name, event_id, message_match_str)
    local test_result = {id = 0, result = false, details = {}}
    local matched_events_from_source, not_operation = match_event_source(event_log_name, source_name)

    if tablelength(matched_events_from_source) > 0 then
        local matched_events_with_message, not_operation = find_event_with_id_with_message(test_id, event_log_name, event_id, message_match_str)
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
