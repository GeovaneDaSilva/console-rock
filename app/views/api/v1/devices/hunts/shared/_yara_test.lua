function execute_yara_scan(file_path, yara_script_url)
    local compiled_rules = nil
    local yara_matches = {}
    local rule_http_status, rule_content = hunter.http_get(yara_script_url)

    if rule_http_status ~= 200 then
        hunter.log("Cannot download yara rule file : "..tostring(yara_script_url), hunter.LOG_LEVEL_ERROR)
        return
    end

    local function yara_callback(result_data)
        if result_data.matched then
            hunter.log("Found a match for yara rule : "..tostring(result_data.identifier) .. " for file : "..tostring(result_data.file_path), hunter.LOG_LEVEL_DEBUG)
            table.insert(yara_matches, result_data)
        end
    end

    local function file_callback(file_info)
        if tablelength(yara_matches) > 5 then
            return true -- arbitrary 5 matches found then stop.
        end

        hunter.log("Yara scanning : "..tostring(file_info.file_path), hunter.LOG_LEVEL_DEBUG)
        hunter.exec_yara_rule(file_info.file_path, compiled_rules, yara_callback)
    end

    hunter.log("Initializing Yara",hunter.LOG_LEVEL_DEBUG)
    hunter.require_yara()
    
    hunter.log("Attempting to compile yara rules ", hunter.LOG_LEVEL_DEBUG)
    compiled_rules = hunter.compile_yara_rule(rule_content)

    hunter.find_files_win(file_path, "*.*", file_callback)

    hunter.destroy_yara_rules(compiled_rules)
    hunter.finalize_yara()

    return yara_matches
end


function evaluate_yara_script(test_id, file_path, yara_script_url)
    local test_result = {id = test_id, result = false, details = {}}
    local yara_matches = execute_yara_scan(file_path, yara_script_url)
    local any_matches = tablelength(yara_matches) > 0

    if any_matches then
        test_result.result = true

        for _,result in ipairs(yara_matches) do

            local formatted_test_result={type="Yara",attributes=result}

            table.insert(test_result.details, formatted_test_result)

        end

    else
        test_result.result = false
    end

    return test_result
end
