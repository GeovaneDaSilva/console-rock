function find_entry_in_driver_list(driver_list,entry_to_find)
  local found_entries = {}
  local not_operation = false
  local bresult = false
  local match_type = "name"
  local patterns = {md5 = [[\b[A-Fa-f0-9]{32}\b]], sha1 = [[\b[A-Fa-f0-9]{40}\b]], sha2 = [[\b[A-Fa-f0-9]{64}\b]]}

  -- Determine what type of entry we're looking for
  for key, pattern in pairs(patterns) do
    matches, num_matches = hunter.regex_match(entry_to_find, pattern)
    if num_matches > 0 then
      match_type = key
    end
  end

  local md5,sha1,sha2 = hunter.hash_file_common(real_path)

  hunter.log("Scanning driver list for match for "..tostring(entry_to_find),hunter.LOG_LEVEL_DEBUG)
  for _,driver in ipairs(driver_list) do
    if type(driver)=='table' then
      local real_path = hunter.nt_to_dos_path(driver.file_name)
      local md5,sha1,sha2 = hunter.hash_file_common(real_path)

      if match_type == "md5" then
        bresult, not_operation = item_compare(entry_to_find, md5)
      elseif match_type == "sha1" then
        bresult, not_operation = item_compare(entry_to_find, sha1)
      elseif match_type == "sha2" then
        bresult, not_operation = item_compare(entry_to_find, sha2)
      elseif match_type == "name" then
        bresult, not_operation = item_compare(entry_to_find, driver.base_name)
      end

      if bresult then
        driver.md5 = md5
        driver.sha1 = sha1
        driver.sha2 = sha2

        local file_attributes = hunter.get_file_attributes(real_path)
        if file_attributes then
            driver.size = tonumber(file_attributes.size)
            driver.last_accessed = tonumber(file_attributes.last_accessed)
            driver.create_time = tonumber(file_attributes.create_time)
            driver.last_write_time = tonumber(file_attributes.last_write_time)
        end
        hunter.log("Found driver list match : "..tostring(entry_to_find),hunter.LOG_LEVEL_TRACE)
        table.insert(found_entries,driver)
      end
    end
  end

  return found_entries, not_operation
end
