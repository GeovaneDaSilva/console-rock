-- call this to match local user names
function find_matching_user(username_to_find)
    local found_users = {}
    hunter.log("Getting Local Users", hunter.LOG_LEVEL_INFO)
    local local_users = hunter.get_local_users()
    if type(local_users) == "table" then
        for _, username in ipairs(local_users) do
            local split_username = string.split(username, "\\")
            local just_username = split_username[tablelength(split_username)]

            bresult, not_operation = item_compare(username_to_find, just_username)
            if bresult then
                table.insert(found_users, just_username)
            end
        end
    end
    return found_users, not_operation
end

function format_user_detail(user)
    local account_enabled,last_logon = hunter.get_account_info(user)
    local groups = hunter.get_groups_for_user(user)
    local detail={user_name=user}
    if account_enabled==true then
        detail.account_enabled="Yes"
    elseif account_enabled==false then
        detail.account_enabled="No"
    else
        detail.account_enabled="unknown"
    end

    if last_logon~=nil and last_logon>0then
        detail.last_logon=hunter.format_time_t(last_logon)
    else
        detail.last_logon="never"
    end

    if tablelength(groups)>0 then
        detail.member_of = groups
    end

    return detail

end

function find_user(test_id, search_str)
    local test_result = {id = test_id, result = false, details = {}}
    local found_users, not_operation = find_matching_user(search_str)

    if tablelength(found_users) > 0 then
      test_result.result = true
      for _, user in ipairs(found_users) do
        local detail = format_user_detail(user)
        table.insert(test_result.details, detail)
      end
    end

    test_result.id = test_id

    return test_result
end

-- Handle a search_str with multipe csv values
function find_users(test_id, search_str)
  local final_test_result = {id=test_id,result=false,details={}}

  local split_search_strs = string.split(search_str, ",")

  for i, search_str in ipairs(split_search_strs) do
    local test_result = find_user(test_id, search_str)

    if test_result.result == true then
      for _,result in ipairs(test_result.details) do

        local formatted_test_result = format_user_detail(result)

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
