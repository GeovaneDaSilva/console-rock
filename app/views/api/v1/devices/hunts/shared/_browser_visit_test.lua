function handle_row(data_store, cols, values, names)
    local new_row = {}
    local skip_row = false
    local url_hash = nil

    for i = 1, cols do
        if names[i] == "last_visit" then
            new_row[names[i]] = math.floor(tonumber(values[i]))
        else
            new_row[names[i]] = values[i]
        end

    end

    if not skip_row then
        data_store[#data_store + 1] = new_row
    end

    return 0
end

-- Note, if the chrome browser is open, the history file will be locked
-- we can work around this by making a copy in our temp dir and using that location.
function copy_history_file(source_path, dest_path)
    local result = nil

    local source_file, errno = io.open(source_path, "rb")
    if (source_file ~= nil) then
        local dest_file, errno = io.open(dest_path, "w+b");
        if dest_file ~= nil then
            local data = source_file:read("*all")
            dest_file:write(data)
            dest_file:close()
            result = dest_path
        else
            hunter.log("failed to open "..dest_path.." for binary write: "..tostring(errno), hunter.LOG_LEVEL_ERROR)
        end
        source_file:close()
    else
        hunter.log("failed to open "..source_path.." for binary read: "..tostring(errno), hunter.LOG_LEVEL_ERROR)
    end

    return result
end


function get_chrome_browser_history(history_path)
    local chrome_history = {}

    hunter.log("getting chrome browser history from "..history_path, hunter.LOG_LEVEL_TRACE)

    local temp_dir = hunter.get_agent_temp()
    local backup_path

    status, err = pcall(function()
        hunter.log("copy_history_file from "..history_path.."\\History to "..temp_dir.."chrome_history", hunter.LOG_LEVEL_TRACE)
        backup_path = copy_history_file(history_path.."\\History", temp_dir.."chrome_history");
        hunter.log("copy_history_file returned : " ..tostring(backup_path), hunter.LOG_LEVEL_TRACE)
    end)

    if not status then
        hunter.log("Error during protected call to backup history file : "..tostring(err), hunter.LOG_LEVEL_ERROR)
    end

    if backup_path ~= nil then
        -- sql = "SELECT id,url,title,visit_count,datetime((last_visit_time/1000000)-11644473600, 'unixepoch', 'localtime') AS last_visit_time,hidden,favicon_id FROM urls;"
        sql = "SELECT id,url,title,visit_count,(last_visit_time/1000000)-11644473600 AS last_visit,hidden FROM urls;"

        hunter.log("sql = "..tostring(sql), hunter.LOG_LEVEL_TRACE)
        hunter.log("dbfile = "..tostring(backup_path), hunter.LOG_LEVEL_TRACE)
        db = sqlite3.open(backup_path, sqlite3.OPEN_READONLY) -- open readonly

        if db ~= nil then
            db:exec(sql, handle_row, chrome_history)
            db:close()
            -- hunter.remove_file(backup_path)
        else
            hunter.log("couldnt open db "..tostring(backup_path), hunter.LOG_LEVEL_ERROR)
        end
    end

    return chrome_history
end


function get_firefox_browser_history(history_path)
    local firefox_history = {}

    -- reset the globals.
    top_visit_url = ""
    top_visit_count = 0
    top_last_visit = ""
    total_urls_visited = 0

    local temp_dir = hunter.get_agent_temp()

    -- at this time, it doesnt appear as though firefox locks the db like chrome does.
    -- will leave this here in case things change
    if do_backup then

        status, err = pcall(function()
            backup_path = copy_history_file(history_path.."\\places.sqlite", temp_dir.."firefox.sqlite");
            hunter.log("copy_history_file returned "..tostring(backup_path), hunter.LOG_LEVEL_TRACE)

        end)
        if not status then
            print(err)
        end
    end

    backup_path = history_path.."\\places.sqlite"
    hunter.log("getting firefox browser history from "..tostring(backup_path), hunter.LOG_LEVEL_TRACE)

    if backup_path ~= nil then
        -- sql = "SELECT id,url,title,visit_count,datetime(last_visit_date/1000000, 'unixepoch', 'localtime') AS last_visit_time,hidden,favicon_id FROM moz_places;"
        sql = "SELECT id,url,title,visit_count,last_visit_date/1000000 AS last_visit,hidden FROM moz_places;"

        db = sqlite3.open(backup_path, sqlite3.OPEN_READONLY) -- open readonly

        if db ~= nil then
            db:exec(sql, handle_row, firefox_history)
            db:close()
            if do_backup then
                hunter.remove_file(backup_path)
            end
        else
            print("couldnt open db ", backup_path)
        end
    end

    return firefox_history
end


local function get_edge_history(user)
    local edge_history = nil
    if user == nil then
        hunter.log("must supply username for get_edge_history", hunter.LOG_LEVEL_ERROR)
        return edge_history
    end
    local tmp_path = agent_options.program_dir.."\\temp\\"..tostring(hunt_id)
    if not hunter.path_exists(tmp_path) then
        hunter.create_directory(tmp_path)
        if not hunter.path_exists(tmp_path) then
            hunter.log("Could not create temporary directory for edge history", hunter.LOG_LEVEL_ERROR)
            return edge_history
        end
    end
    local history_path = hunter.expand_env_string("%SystemDrive%\\Users\\"..user.."\\AppData\\Local\\Microsoft\\Windows\\WebCache")
    local locked_file = history_path.."\\WebCacheV01.dat"
    if hunter.path_exists(locked_file) then
        hunter.log("Found Edge DB : "..tostring(locked_file),hunter.LOG_LEVEL_INFO)
        local function vss_copy_call_back(file_info)
            hunter.log("enter vss_copy_call_back with file : "..tostring(file_info.file_path),hunter.LOG_LEVEL_DEBUG)
            local dir_name,file_name = hunter.split_path(file_info.file_path)
            local unlocked_file = tmp_path.."\\"..file_name
            if hunter.path_exists(unlocked_file) then
                hunter.remove_file(unlocked_file)
            end
            hunter.log("Shadow copying : "..tostring(file_info.file_path).." ==> "..tostring(unlocked_file),hunter.LOG_LEVEL_DEBUG)
            local newfile = hunter.vss_copy_locked_file(file_info.file_path,unlocked_file)
            if newfile==nil then
                hunter.log("Failed to shadow copy file "..tostring(locked_file),hunter.LOG_LEVEL_ERROR)
            end
        end
        -- attempt to copy all the files to our temp location.
        hunter.log("Gathering locked files of edge database from : "..tostring(history_path),hunter.LOG_LEVEL_INFO)
        hunter.find_files_win(history_path, '*', vss_copy_call_back)
        local unlocked_file = tmp_path.."\\WebCacheV01.dat"
        if hunter.path_exists(unlocked_file) then
            hunter.log("Attempting to read edge_history from : "..tostring(unlocked_file),hunter.LOG_LEVEL_DEBUG)
            edge_history = hunter.read_edge_history(unlocked_file)
            local bresult=hunter.remove_tree(tmp_path)
            if not bresult then
                hunter.log("Failed to delete temporary path : "..tostring(unlocked_file),hunter.LOG_LEVEL_WARNING)
            end
        else
            hunter.log("shadow copy of file : "..tostring(unlocked_file).." does not exist. Failed to collect edge history",hunter.LOG_LEVEL_WARNING)
        end
    else
        hunter.log("No edge history database found for user : "..tostring(user),hunter.LOG_LEVEL_DEBUG)
    end
    return edge_history
end

function get_browser_history()

    local browser_history = {}
    local os_string = hunter.get_os_version()
    local history_path

    -- get the list of user profiles (home directories) on the box
    local profile_path = hunter.expand_env_string('%SystemDrive%\\Users')
    local profile_list = hunter.find_subdirectories(profile_path)
    -- find the domain membership of this computer
    local wksta_info = hunter.get_wksta_info()

    -- for each user gather the history
    for _,user_profile in ipairs(profile_list) do

        local user
        local base_user

        hunter.log("found user profile : "..tostring(user_profile.path),hunter.LOG_LEVEL_DEBUG)
        local user_pos = user_profile.path:match('^.*()\\')
        if user_pos then
            user_pos = user_pos + 1
            user=user_profile.path:sub(user_pos)
        else
            user=user_profile.path
        end

        if hunter.trustee_exists(user) then
            -- this is a local user account
            hunter.log("User : "..tostring(user).." is a local account",hunter.LOG_LEVEL_INFO)
            user = wksta_info.computer_name.."\\"..user
        else
            -- if this computer is a member of a domain could be a domain user
            -- otherwise its a generic folder
            if wksta_info.domain_name~="WORKGROUP" then
                user=wksta_info.domain_name.."\\"..user
                hunter.log("Must be a domain user "..tostring(user),hunter.LOG_LEVEL_DEBUG)
            else
                hunter.log("Not a local or domain user, must be a shared folder : "..tostring(user),hunter.LOG_LEVEL_DEBUG)
            end
        end


        hunter.log("getting browser history for user : "..tostring(user),hunter.LOG_LEVEL_DEBUG)
        -- find out if there is a domain name attached to the user and remove it
        local slash_pos= user:find("\\")
        if slash_pos then
            slash_pos=slash_pos+1
            base_user=user:sub(slash_pos)
            hunter.log("base user name is : "..tostring(base_user),hunter.LOG_LEVEL_DEBUG)
        else
            base_user=user
        end

        -- first get chrome
        local user_dir = user_profile.path

        if string.find(os_string,"XP") then
            history_path = user_dir.."\\Local Setting\\Application Data\\Google\\Chrome\\User Data\\Default"

        else
            history_path = user_dir.."\\AppData\\Local\\Google\\Chrome\\User Data\\Default"

        end
        if hunter.path_exists(history_path) then
            local chrome_history = get_chrome_browser_history(history_path)
            if type(chrome_history)=="table" then
                browser_history.chrome={}
                browser_history.chrome.user=user
                table.insert(browser_history.chrome,chrome_history)
            end
        else
            hunter.log("Chrome browser not detected for user : "..tostring(user)..". skipping history collection",hunter.LOG_LEVEL_INFO)
        end

        -- now firefox
        if (string.find(os_string,"XP")) then
            ffox_path = user_dir.."\\Application Data\\Mozilla\\Firefox"
        else
            ffox_path = user_dir.."\\AppData\\Roaming\\Mozilla\\Firefox"
        end

        sub_path = hunter.get_profile_option(ffox_path.."\\profiles.ini","Profile0","Path")

        history_path = ffox_path.."\\"..sub_path

        if hunter.path_exists(history_path) then
            local ffox_history = get_firefox_browser_history(history_path)
            if type(ffox_history)=="table" then
                browser_history.firefox={}
                browser_history.firefox.user=user
                table.insert(browser_history.firefox,ffox_history)
            end
        else
            hunter.log("Firefox browser not detected for user : "..tostring(user)..". skipping history collection",hunter.LOG_LEVEL_INFO)
        end


--         local e_history = get_edge_history(base_user)
--         if type(e_history)=='table' then
--             local transformed_history = {}
--             browser_history.edge={}
--             browser_history.edge.user=user

--             for container,visit_group in pairs(e_history) do
--                 for i,visit  in ipairs(visit_group) do
--                     local transformed_visit = {}

--                     transformed_visit.url = visit.Url
--                     transformed_visit.last_visit = visit.AccessedTime

--                     table.insert(transformed_history, transformed_visit)
--                 end
--             end

--             table.insert(browser_history.edge,transformed_history)
--         end


        local ie_history = hunter.get_ie_browser_history()
        if type(ie_history)=="table" then
            browser_history.ie={}
            browser_history.ie.user=user
            table.insert(browser_history.ie,ie_history)
        end

    end

    return browser_history

end

function find_visit_in_history(browser_history,url_to_find)
  local found_visits = {}
  local not_operation = false
  local bresult = false

  hunter.log("Scanning browser_history list for match for "..tostring(url_to_find),hunter.LOG_LEVEL_DEBUG)
  for browser,history in pairs(browser_history) do
    hunter.log("checking browser: "..tostring(browser),hunter.LOG_LEVEL_TRACE)
    if type(history)=='table' then
      for _,visits in ipairs(history) do
        if type(visits)=='table' then
          for _,visit in ipairs(visits) do
            hunter.log("Checking visit : "..tostring(visit.url),hunter.LOG_LEVEL_TRACE)
            bresult,not_operation=item_compare(url_to_find,visit.url)
            if bresult then
              hunter.log("Found browser visit match : "..tostring(visit.url),hunter.LOG_LEVEL_TRACE)
              visit.browser=browser
              visit.user = history.user
              table.insert(found_visits,visit)
            end
          end
        end
      end
    end
  end
  hunter.log("find_visit_in_history returning "..tostring(found_visits).." "..tostring(tablelength(found_visits)).." not_operation = "..tostring(not_operation),hunter.LOG_LEVEL_TRACE)

  return found_visits, not_operation
end

local browser_mutex = nil

function open_browser_mutex()
    local browser_mutex=nil

    local status,smem_object = hunter.read_shared_memory("browser_mutex")
    if status and smem_object then
        hunter.log("browser_mutex retrieved from shared_memory_object",hunter.LOG_LEVEL_TRACE)
        browser_mutex = smem_object.data
    end
    if not browser_mutex then
        hunter.log("browser_mutex is nil, creating new",hunter.LOG_LEVEL_TRACE)
        browser_mutex=hunter.create_mutex()
        local shared_memory_object = {}
        shared_memory_object.type=0
        shared_memory_object.flags=0
        shared_memory_object.message="browser history mutex"
        shared_memory_object.data=browser_mutex
        hunter.log("writing browser mutex to shared memmory handle = "..tostring(shared_memory_object.data),hunter.LOG_LEVEL_TRACE)
        local bresult = hunter.write_shared_memory("browser_mutex",shared_memory_object)
        if not bresult then
            hunter.log("Failed to store hash db handle to shared memory.",hunter.LOG_LEVEL_WARNING)
        end
    end
    return browser_mutex
end

function get_cached_browser_data()
    local thirty_seconds = 30
    local data_is_old = true
    local browser_history = nil

    local status,smem_object = hunter.read_shared_memory("browser_data")
    if status and smem_object then
        hunter.log("read browser data from shared memory, rehydrating",hunter.LOG_LEVEL_DEBUG)
        browser_history = cjson.decode(smem_object.message)
        if type(browser_history)=="table" then
            local history_age = hunter.timestamp() - browser_history.updated_at
            hunter.log("Checking history age "..tostring(history_age),hunter.LOG_LEVEL_DEBUG)
            if history_age < thirty_seconds then
                data_is_old = false
            end
        end
    end
    return data_is_old,browser_history
end

function update_history_cache()

    hunter.log("browser history appears to be out of date. attempting to get mutex lock.",hunter.LOG_LEVEL_DEBUG)
    hunter.lock_mutex(browser_mutex)
    hunter.log("browser history mutex lock acquired",hunter.LOG_LEVEL_DEBUG)
    local data_needs_updating, browser_history, smem_object = get_cached_browser_data() -- check once more before we collect data
    if data_needs_updating then
        hunter.log("browser_history data is out of date. Collecting fresh data...",hunter.LOG_LEVEL_DEBUG)
        browser_history = get_browser_history()
        if type(browser_history)=="table" then
            local shared_memory_object = {}
            shared_memory_object.type=0
            shared_memory_object.flags=0
            browser_history.updated_at = hunter.timestamp()
            shared_memory_object.message = cjson.encode(browser_history)
            local bresult = hunter.write_shared_memory("browser_data",shared_memory_object)
            if not bresult then
                hunter.log("Failed to store browser history to shared memory.",hunter.LOG_LEVEL_WARNING)
            end
        end
    else
        hunter.log("browser_history was updated by another thread...",hunter.LOG_LEVEL_DEBUG)
    end
    hunter.unlock_mutex(browser_mutex)
    hunter.log("browser history mutex released",hunter.LOG_LEVEL_DEBUG)
    return browser_history
end

browser_mutex = open_browser_mutex()
if not browser_mutex then
    hunter.log("Failed to open / create browser history mutex",hunter.LOG_LEVEL_ERROR)
    return
end

local data_needs_updating, browser_history = get_cached_browser_data()
if data_needs_updating then
    browser_history = update_history_cache()
end


function find_browser_visit(test_id, search_str)
  local test_result = {id=test_id,result=false,details={}}
  local found_visits,not_operation = find_visit_in_history(browser_history,search_str)
  if not_operation and tablelength(found_visits)>0 then
    -- this is a not exist operation that failed
    hunter.log("Not operation failed",hunter.LOG_LEVEL_TRACE)
    test_result.result=false
  elseif not_operation and tablelength(found_visits)==0 then
    -- this is a not operation that passed
    hunter.log("Not operation passed",hunter.LOG_LEVEL_TRACE)
    test_result.result=true
  elseif tablelength(found_visits)>0 and not_operation==false then
    -- this is a regular match (exists) operation that passed
    hunter.log("Match operation passed",hunter.LOG_LEVEL_TRACE)
    test_result.result=true
  else
    hunter.log("Match operation failed",hunter.LOG_LEVEL_TRACE)
  end
  if agent_options.verbosity<=hunter.LOG_LEVEL_DEBUG then
    test_result.search=search_str
  end

  if tablelength(found_visits)>0 then
    test_result.details=found_visits
  end

  return test_result
end

-- Handle a serach_str with multipe csv values
function find_browser_visits(test_id, search_strs)
  local final_test_result = {id=test_id,result=false,details={}}

  local split_browser_visits = split(search_strs, "[^,%s]+")

  for i, search_str in ipairs(split_browser_visits) do
    local test_result = find_browser_visit(test_id, search_str)

    if test_result.result == true then

      for _,result in ipairs(test_result.details) do

        local formatted_test_result={type="Browser",attributes=result}

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
