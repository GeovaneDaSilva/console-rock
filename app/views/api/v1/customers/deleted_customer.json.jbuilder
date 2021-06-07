json.customer do
  json.config do
    json.uninstall true

    json.extract! @customer.setting, :offline, :super, :polling, :report_agent_errors, :app_result_cache_age
    json.verbosity Setting.verbosities[@customer.setting.verbosity]
    json.url root_url
    json.license_key @customer.license_key
    json.default_start "#{ENV['AGENT_FILE_NAME']}.lua"
    json.ws_url "wss://#{ENV.fetch('AGENT_WS_HOST', "ws.#{request.host}")}/signed/listen/foo/"
    json.parallel_sub_task_count @customer.setting.parallel_sub_task_count
    json.file_hash_refresh_interval @customer.setting.file_hash_refresh_interval
    json.max_cpu_usage @customer.setting.max_cpu_usage
    json.max_memory_usage @customer.setting.max_memory_usage
    json.max_sustained_memory_usage @customer.setting.max_sustained_memory_usage
    json.full_disk_scan_time @customer.setting.full_disk_scan_time
    json.admin_configs {}
  end
end
