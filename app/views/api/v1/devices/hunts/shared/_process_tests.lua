
process_factory = process_object_factory()
if process_factory==nil then
  hunter.log("process_test: Failed to create process_object_factory instance",hunter.LOG_LEVEL_FATAL)
  return
end


function get_running_processes()

    local bresult = hunter.adjust_process_privilege(hunter.SE_DEBUG_NAME)
    if not bresult then
        hunter.log("Failed to adjust process privilege to : "..tostring(hunter.SE_DEBUG_NAME), hunter.LOG_LEVEL_DEBUG)
    end

    local running_processes = {}
    local process_list = hunter.get_process_list()


    for _, process in pairs(process_list) do
        process = process_factory.get_process_from_pid(process.process_id)
        if type(process) == "table" then
            process.file_owner=hunter.get_file_owner(process.file_path)
            table.insert(running_processes,process)

        end
    end

    return running_processes

end

function get_hidden_processes(running_processes)

  local processes = hunter.get_process_list()
  local threads = hunter.get_threads()

  local process_info={}

  local orphaned_threads = {}

  for index,thread in ipairs(threads) do

    local owner_found = false
    -- loop through process list, looking for thread owner.
    for k,v in pairs(processes) do
      if type(v)=="table" then
        if v.process_id==thread.process_owner or v.parent_process_id==thread.process_owner then
          owner_found = true
          break
        end
      end
      if owner_found then
        break
      end
    end
    if not owner_found then
      table.insert(orphaned_threads,thread)
      hunter.log("Warning Thread "..tostring(thread.thread_id).." Cannot find owning process "..tostring(thread.process_owner),hunter.LOG_LEVEL_INFO)
    end
  end


  local num_threads=tablelength(orphaned_threads)

  if num_threads>0 then
    hunter.log("Found "..tostring(num_threads).." running on stealth processes",hunter.LOG_LEVEL_INFO)
    for _,thread in ipairs(orphaned_threads) do
        process = process_factory.get_process_from_pid(thread.process_owner)
        if type(process) == "table" then
            process.file_owner=hunter.get_file_owner(process.file_path)
            process_file_info.hidden=true
            table.insert(running_processes,process)

        end
    end
  
  end

  return running_processes

end


function find_process_in_processes(running_processes,process_to_find)
  local found_processes = {}
  local not_operation = false
  local bresult = false

  hunter.log("Scanning process list for match for "..tostring(process_to_find),hunter.LOG_LEVEL_DEBUG)
  for _,process in ipairs(running_processes) do

    local match_component=process.file_name
    local patterns = { md5=[[\b[A-Fa-f0-9]{32}\b]],sha1=[[\b[A-Fa-f0-9]{40}\b]],sha2=[[\b[A-Fa-f0-9]{64}\b]]}

    for key,pattern in pairs(patterns) do
      matches,num_matches = hunter.regex_match(process_to_find,pattern)
      if num_matches>0 then
        if key=="md5" then
          match_component=process.md5
          break
        elseif key=="sha1" then
          match_component=process.sha1
          break
        elseif key=="sha2" then
          match_component=process.sha2
          break
        end
      end
    end

    bresult,not_operation=item_compare(process_to_find,match_component)
    if bresult then
      hunter.log("Found process match : "..tostring(process.file_name),hunter.LOG_LEVEL_TRACE)
      table.insert(found_processes,process)
    end
  end
  hunter.log("find_process_in_processes returning "..tostring(found_processes).." "..tostring(tablelength(found_processes)).." not_operation = "..tostring(not_operation),hunter.LOG_LEVEL_TRACE)
  return found_processes, not_operation
end

function find_process(test_id, search_str,running_processes)
  local test_result = { id=0,result=false,details={}}
  local found_processes,not_operation = find_process_in_processes(running_processes,search_str)
  if not_operation and tablelength(found_processes)>0 then
    -- this is a not exist operation that failed
    hunter.log("Not operation failed",hunter.LOG_LEVEL_DEBUG)
    test_result.result=false
  elseif not_operation and tablelength(found_processes)==0 then
    -- this is a not operation that passed
    hunter.log("Not operation passed",hunter.LOG_LEVEL_DEBUG)
    test_result.result=true
  elseif tablelength(found_processes)>0 and not_operation==false then
    -- this is a regular match (exists) operation that passed
    hunter.log("Match operation passed",hunter.LOG_LEVEL_DEBUG)
    test_result.result=true
  else
    hunter.log("Match operation failed",hunter.LOG_LEVEL_DEBUG)
  end
  if agent_options.verbosity<=hunter.LOG_LEVEL_DEBUG then
    test_result.search=search_str
  end

  if tablelength(found_processes)>0 then
    test_result.details=found_processes
  end

  test_result.id = test_id

  return test_result
end

-- Handle a serach_str with multipe csv values
function find_processes(test_id, search_strs)
  local final_test_result = {id=test_id,result=false,details={}}

  local split_search_strs = split(search_strs, "[^,%s]+")

  hunter.log("Collecting running_processes",hunter.LOG_LEVEL_DEBUG)
  local running_processes = get_running_processes()
  hunter.log("Collecting hidden_processes",hunter.LOG_LEVEL_DEBUG)
  running_processes = get_hidden_processes(running_processes)


  for i, search_str in ipairs(split_search_strs) do
    local test_result = find_process(test_id, search_str, running_processes)

    if test_result.result == true then

      -- lets get this into a standardized schema for posting to cloud.
      for _,result in ipairs(test_result.details) do
        
        table.insert(final_test_result.details, process_factory.process_to_report_format(result))

      end
    end
    hunter.wait(wait_time)
  end

  if tablelength(final_test_result.details)>0 then
    final_test_result.result = true
  end

  return final_test_result
end
