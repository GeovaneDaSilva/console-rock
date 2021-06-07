# Summarize account stats
module AccountStatsable
  def account
    raise NotImplementedError
  end

  def historical_counts(count: 2)
    (-count..0).each_with_object({}) do |i, hash|
      month = i.abs.months.ago
      hash[month.strftime("%b")] = {
        malicious:     historical_hunt_result_counts_by_month(type: :malicious, date_month: month) +
                       historical_app_result_counts_by_month(type: :malicious, date_month: month),

        suspicious:    historical_hunt_result_counts_by_month(type: :suspicious, date_month: month) +
                       historical_app_result_counts_by_month(type: :suspicious, date_month: month),

        informational: historical_hunt_result_counts_by_month(type: :informational, date_month: month) +
                       historical_app_result_counts_by_month(type: :informational, date_month: month),
        descendants:   historical_descendants(date_month: month).size
      }

      hash
    end
  end

  def totals
    {
      malicious:     hunt_results.malicious.size +
        app_results.malicious.size,

      suspicious:    hunt_results.suspicious.size +
        app_results.suspicious.size,

      informational: hunt_results.informational.size +
        app_results.informational.size
    }
  end

  def historical_hunt_result_counts_by_month(type:, date_month:)
    if date_month.strftime("%m-%y") == Time.current.strftime("%m-%y")
      hunt_results.within_date_month(date_month).send(type).size
    else
      Rails.cache.fetch(["v1/stats/account/historical-hunts", date_month.strftime("%m-%y"), account.id]) do
        hunt_results.within_date_month(date_month).send(type).size
      end
    end
  end

  def historical_app_result_counts_by_month(type:, date_month:)
    if date_month.strftime("%m-%y") == Time.current.strftime("%m-%y")
      app_results.within_date_month(date_month).send(type)
                 .size
    else
      cache_keys = ["v1/stats/account/historical-app-results", date_month.strftime("%m-%y"), account.id]

      Rails.cache.fetch(cache_keys) do
        app_results.within_date_month(date_month).send(type)
                   .size
      end
    end
  end

  def historical_descendants(date_month:)
    account.self_and_all_descendant_customers.where("created_at <= ?", date_month.end_of_month)
  end

  private

  def hunt_results
    account.all_descendant_hunt_results.unarchived
  end

  def app_results
    account.all_descendant_app_results
  end
end
