json.id hunt.id
json.name hunt.name
json.revision hunt.revision
json.continuous hunt.continuous
json.updated_at hunt.updated_at.in_time_zone(device.timezone).to_i
json.script_url api_device_hunt_url(device, hunt.file_identifier, format: :lua)
json.enabled HuntPolicy.new(nil, hunt).runnable?
