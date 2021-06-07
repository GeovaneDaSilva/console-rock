module Apps
  module Results
    # Asynchronously updates app counter caches
    # TODO: find a better way
    class UpdateCounterCaches
      def initialize(increment, app_result_ids)
        @app_results = Apps::Result.where(id: app_result_ids)
        @increment = increment == "decrement" ? -1 : 1
      rescue ActiveRecord::RecordNotFound
        @app_results = []
      end

      def call
        return if @app_results.blank?

        @app_results.each do |result|
          CounterCache.update_counters result.counter_cache.id, count: @increment

          result.device.update_counters(result.verdict) if respond_to?(:device)
        end
      end
    end
  end
end
