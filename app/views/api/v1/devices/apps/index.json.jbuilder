json.cache! ["v1/apps-for-device", all_account_apps, apps, device.id, *device.customer.subscription_cache_keys] do
  json.total_count apps.total_count
  json.current_page apps.current_page
  json.total_pages apps.total_pages

  json.apps apps, partial: "app", as: :app
end
