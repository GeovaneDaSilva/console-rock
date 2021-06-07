json.cache! ["v1/stats-for-device", @device] do
  json.totals @totals
  json.historical_counts @historical_counts
end
