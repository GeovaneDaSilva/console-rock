json.cache! ["v1/stats-for-account", @account] do
  json.totals @totals
  json.historical_counts @historical_counts
end
