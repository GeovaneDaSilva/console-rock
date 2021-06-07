json.title do
  json.text do
    json.headline "#{device.hostname} Attack Timeline"
    json.text "The timeline view displays detected events in chronological order. This provides a dramatic visualization of the attackers intended objectives, tactics and techniques and helps you quickly interrupt the attack process and reduce dwell time."
  end
end

json.cache! ["v1/devices/r/timeline/json", app_results, ttps, current_user&.timezone] do
  json.events app_results, partial: "app_result", as: :app_result
end
