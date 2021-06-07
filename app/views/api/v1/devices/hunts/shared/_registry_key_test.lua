if not winreg then
    hunter.require_winreg()
end

function split_out_main_and_sub_key(full_key)
    local split_key = string.split(full_key, "\\")
    local sub_key = split_key[tablelength(split_key)]

    split_key[tablelength(split_key)]=nil

    local main_key = table.concat(split_key,"\\")

    return main_key, sub_key
end


-- call this to find out if a specific registry key exists
function has_key(key_name)
    -- example key [[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall]]
    local bresult = false

    local status, err = pcall(function()
      hkey = winreg.openkey(key_name, "r")
      if hkey then
          bresult = true
          hkey:close()
      end

      return bresult

    end)

    local main_key
    local sub_key
    main_key, sub_key = split_out_main_and_sub_key(key_name)
    local status, err = pcall(function()
      hkey = winreg.openkey(main_key, "r")
      if hkey then
        if hkey:getvalue(sub_key) then
          bresult = true
        end
        hkey:close()
      end
    end)

    return bresult

end

-- call this to match regsistry values
function compare_key_value(full_key, expected_value)
    local main_key
    local sub_key
    local matching_values = {}
    local bresult = false
    local not_operation = false

    main_key, sub_key = split_out_main_and_sub_key(full_key)

    hkey = winreg.openkey(main_key, "r")
    if hkey then
        local value = hkey:getvalue(sub_key)
        if type(value) ~= 'string' then
            --  assume numeric
            bresult = (value == expected_value)
        else
            bresult, not_operation = item_compare(expected_value, value)
        end
        if bresult then
            local value_data = {}
            value_data.main_key = main_key
            value_data.sub_key = sub_key
            value_data.value = value
            table.insert(matching_values, value_data)
        end
        hkey:close()
    end
    return matching_values, not_operation
end

-- Find a registry key with a value similar to
function find_registry_key_with_value(test_id, registry_key, match_value)
    local test_result = {id = 0, result = false, details = {}}
    local key_exists = has_key(registry_key)

    if match_value == false then
      -- Checking for the absence of they key
      test_result.result = not key_exists
    elseif match_value == true then
      -- Checking for the existance of the key
      test_result.result = key_exists
    else
      -- Check value of key
      if key_exists then
        local matched_values
        local not_operation

        matched_values, not_operation = compare_key_value(registry_key, match_value)
        local any_matches = tablelength(matched_values) > 0

        if any_matches and not_operation == false then
          -- Return true, there were matches
          test_result.result = true
          test_result.details = matched_values
        elseif any_matches and not_operation then
          -- Return false, there were matches when none were expected
          test_result.result = false
          test_result.details = matched_values
        elseif any_matches == false then
          test_result.result = false
        end
      else
        test_result.result = false
      end
    end

    test_result.id = test_id
    return test_result
end

-- Handle a serach_str with multipe csv values
function find_registry_key_with_values(test_id, search_strs, match_value)
  local final_test_result = {id=test_id,result=false,details={}}

  -- local split_search_strs = split(search_strs, "[^,%s]+")
  local split_search_strs = string.split(search_strs, ",")

  for i, search_str in ipairs(split_search_strs) do
    local test_result = find_registry_key_with_value(test_id, search_str, match_value)

    if test_result.result == true then

      for _,result in ipairs(test_result.details) do

        local formatted_test_result={type="Registry",attributes=result}

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


