module Utils
  # nodoc
  class Utilities
    def initialize(method, params = {})
      @method = method
      @params = params
    end

    def call
      send(@method, *@params)
    end

    private

    def update_counter_cache(account_id)
      DatabaseTimeout.timeout(0) do
        account = Account.find_by(id: account_id)
        return if account.nil?

        account.all_descendant_app_counter_caches.find_each do |cache|
          next if cache.count > 1000

          new_count = account.all_descendant_app_results.where(
            account_path: cache.account_path,
            app_id:       cache.app_id,
            device_id:    cache.device_id,
            verdict:      cache.verdict,
            incident_id:  nil
          ).count
          cache.update(count: new_count)
        end
      end
    end

    def update_app_counter_caches
      # PIPELINE_TRIALS.each do |account_id|
      #   ServiceRunnerJob.perform_later("Utils::Utilities", "update_counter_cache", account_id)
      # end
      Provider.where("paid_thru > ?", DateTime.current.beginning_of_day)
              .pluck(:id).sort.reverse.each do |provider_id|
        next if provider_id == 2617

        update_counter_cache(provider_id)
      end
    end
  end
end
