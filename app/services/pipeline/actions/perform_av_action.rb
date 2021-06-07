module Pipeline
  module Actions
    # Perform AV action for the given app result(s)
    class PerformAvAction
      def initialize(_message, rule_id, app_result_ids, av_vendor, av_action, av_action_options)
        @rule_id          = rule_id
        @app_result_ids   = Array(app_result_ids)
        @av_vendor        = av_vendor.camelize
        @av_action        = av_action
        @av_action_option = av_action_options.first
      end

      def call
        return if app_results.blank?

        action = @av_action.delete(" ")
        case action
        when "AnalystVerdict"
          ServiceRunnerJob.perform_later(
            "#{@av_vendor}::Manage::#{action}", @app_result_ids, @av_action_option
          )
        else
          app_results.each do |app_result|
            value = fetch_value(app_result)
            ServiceRunnerJob.perform_later("#{@av_vendor}::Manage::#{action}", app_result.id, value)
          end
        end
      end

      private

      def app_results
        @app_results ||= ::Apps::Result.find(@app_result_ids)
      rescue ActiveRecord::RecordNotFound
        Rails.logger.error(
          "Failed - logic rule #{@rule_id} - av action #{@av_action} - app result(s) #{@app_result_ids}"
        )
        @app_results = []
      end

      def fetch_value(app_result)
        case @av_action_option
        when "by file hash"
          app_result&.details&.filecontenthash
        else
          @av_action_option
        end
      end
    end
  end
end
