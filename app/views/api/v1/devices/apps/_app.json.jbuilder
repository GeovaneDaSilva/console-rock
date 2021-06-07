json.cache! ["v3/app-for-device", all_account_apps, app, device.id, *device.customer.subscription_cache_keys] do
  account_apps = all_account_apps.select { |account_app|  account_app.app_id == app.id }
  enabled_account_app = account_apps.find { |account_app| account_app.disabled_at.nil? && account_app.enabled_at.present? }

  json.id app.id
  json.title app.title
  json.updated_at app.updated_at.in_time_zone(device.timezone).to_i
  json.platforms app.platforms || []

  if enabled_account_app
    json.script_url api_device_app_url(device, enabled_account_app, format: :lua)
    json.enabled Accounts::AppPolicy.new(device.account, app).runnable?
  elsif account_apps.any?
    json.script_url api_device_app_url(device, account_apps.first, format: :lua)
    json.enabled Accounts::AppPolicy.new(device.account, app).runnable?
  else
    json.script_url api_device_app_url(device, 0, format: :lua)
    json.enabled false
  end
end
