app = apps.find { |i_app| i_app.id == app_result.app_id }

json.unique_id "app-result-#{app_result.id}"
json.group app_result.verdict.to_s.humanize + " Events"
json.background do
  json.url app.display_image&.url || asset_path("default-app-display-image.jpg")
end
json.text do
  ttp = ttps.find { |i_ttp| i_ttp.id == app_result.details.ttp_id } if app_result.details.ttp_id
  json.headline ttp&.tactic || app.title
  json.text  Devices::R::BaseController.renderer.render(
    partial: "devices/r/timelines/app_result",
    locals:  { app_result: app_result, app: app, ttp: ttp, device: device, current_user: current_user }
  ).squish
end
json.start_date do
  start_date = app_result.detection_date.in_time_zone(device.timezone)
  json.year start_date.year
  json.month start_date.month
  json.day start_date.day
  json.hour start_date.hour
  json.minute start_date.min
  json.second start_date.sec
  json.millisecond start_date.subsec.to_f
end
