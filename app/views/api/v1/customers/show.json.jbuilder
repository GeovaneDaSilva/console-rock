# Update the deleted_customer template with any addtional config paramters specified here
json.cache! ["v3", @customer, ENV["AGENT_WS_HOST"]&.parameterize], expires_in: 1.week do
  json.customer do
    json.config do
      json.extract! @customer.setting, :uninstall, :offline, :super, :polling, :report_agent_errors, :app_result_cache_age
      json.verbosity Setting.verbosities[@customer.setting.verbosity]
      json.url @customer.setting.url.presence || root_url
      json.license_key @customer.license_key
      json.default_start "#{ENV['AGENT_FILE_NAME']}.lua"
      json.cache! ["v2", @customer.license_key, ENV["AGENT_WS_HOST"]&.parameterize], expires_in: 1.week do
        json.ws_url "wss://#{ENV.fetch('AGENT_WS_HOST', "ws.#{request.host}")}/signed/listen/#{@customer.signed_license_key}/"
      end
      json.parallel_sub_task_count @customer.setting.parallel_sub_task_count
      json.file_hash_refresh_interval @customer.setting.file_hash_refresh_interval
      json.max_cpu_usage @customer.setting.max_cpu_usage
      json.max_memory_usage @customer.setting.max_memory_usage
      json.max_sustained_memory_usage @customer.setting.max_sustained_memory_usage
      json.full_disk_scan_time @customer.setting.full_disk_scan_time
      json.managed @customer.managed?
      json.admin_configs @customer.setting.admin_config
    end
  end
end
