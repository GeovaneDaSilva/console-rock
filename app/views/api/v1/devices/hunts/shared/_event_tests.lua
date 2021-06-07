function match_event_message(log_name, event_message)
    local found_events = {}
    local bresult = false
    local not_operation = false

    local function log_callback(event_info)
        bresult, not_operation = item_compare(event_message, event_info.message)
        if bresult then
            table.insert(found_events, event_info)
        end
    end

    hunter.read_event_channel(log_name,nil,log_callback)

    return found_events, not_operation
end


function match_event_message_in_events(select_events, event_message)
    local found_events = {}
    local bresult = false
    local not_operation = false

    for _, event_info in ipairs(select_events) do
        bresult, not_operation = item_compare(event_message, event_info.message)
        if bresult then
            table.insert(found_events, event_info)
        end
    end

    return found_events, not_operation
end
