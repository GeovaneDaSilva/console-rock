# Summarize device stats
module DeviceStatsable
  def device
    return super if super

    raise NotImplementedError
  end

  def historical_counts(count: 3)
    (-count..0).each_with_object({}) do |i, hash|
      month = i.abs.months.ago
      hash[month.strftime("%b")] = {
        malicious:     historical_hunt_result_counts_by_month(type: :malicious, date_month: month) +
                       historical_app_result_counts_by_month(type: :malicious, date_month: month),

        suspicious:    historical_hunt_result_counts_by_month(type: :suspicious, date_month: month) +
                       historical_app_result_counts_by_month(type: :suspicious, date_month: month),

        informational: historical_hunt_result_counts_by_month(type: :informational, date_month: month) +
                       historical_app_result_counts_by_month(type: :informational, date_month: month)
      }

      hash
    end
  end

  def totals
    hunt_results = Devices::RecentHuntResult.new(device)
    app_results = Devices::RecentAppResult.new(device)

    Rails.cache.fetch(["v1/stats/device/totals", hunt_results, app_results]) do
      {
        malicious:     hunt_results.of_type(type: :malicious).positive.unarchived.size +
          app_results.of_type(type: :malicious).size,

        suspicious:    hunt_results.of_type(type: :suspicious).positive.unarchived.size +
          app_results.of_type(type: :suspicious).size,

        informational: hunt_results.of_type(type: :informational).positive.unarchived.size +
          app_results.of_type(type: :informational).size
      }
    end
  end

  def historical_hunt_result_counts_by_month(type:, date_month:)
    hunt_results = Devices::RecentHuntResult.new(device)

    Rails.cache.fetch(["v1/stats/device/historical-hunts", hunt_results, type, date_month]) do
      hunt_results.of_type_within_date_month(type: type, date_month: date_month)
                  .positive
                  .unarchived
                  .size
    end
  end

  def historical_app_result_counts_by_month(type:, date_month:)
    app_results = Devices::RecentAppResult.new(device)

    Rails.cache.fetch(["v1/stats/device/historical-app-results", app_results, type, date_month]) do
      app_results.of_type_within_date_month(type: type, date_month: date_month)
                 .size
    end
  end
end
