module Pipeline
  module Actions
    # Isolate the device for the given app result(s)
    class Isolate
      def initialize(_message, rule_id, app_result_ids, *_options)
        @rule_id        = rule_id
        @app_result_ids = Array(app_result_ids)
      end

      def call
        return if app_results.blank?

        message = { type: "isolate_device", payload: {} }.to_json
        app_results.each do |app_result|
          ServiceRunnerJob.perform_later("DeviceBroadcasts::Device", app_result.device_id, message)
        end
      end

      private

      def app_results
        @app_results ||= ::Apps::Result.find(@app_result_ids)
      rescue ActiveRecord::RecordNotFound
        Rails.logger.error(
          "Failed - logic rule #{@rule_id} - isolate device for app result(s) #{@app_result_ids}"
        )
        @app_results = []
      end
    end
  end
end
