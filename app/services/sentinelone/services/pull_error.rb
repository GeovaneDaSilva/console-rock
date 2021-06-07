# :nodoc
module Sentinelone
  # :nodoc
  module Services
    # :nodoc
    class PullError
      def initialize(error, app_id, cred)
        @error = error
        @app_id = app_id || Apps::SentineloneApp.first.id
        @customer = cred.account
      end

      def call
        error_message = nil
        begin
          if @error.dig("errors").class == Array
            error_message = @error.dig("errors").first.dig("detail") || @error.to_json
          elsif !@error.dig("errors").nil? # this is probably not going to happen
            # (assuming sentinelone has more consistent error messages than MS)
            error_message = @error.dig("errors")
          end
        rescue NoMethodError
          error_message = @error.is_a?(Hash) ? @error.to_json : @error
        end

        Rails.logger.error("Sentinelone Error fail on error #{@error.to_json}") if error_message.nil?

        err = Apps::SentineloneResult.where(app_id: @app_id, customer_id: @customer.id, verdict: "malicious",
          value: error_message).first_or_create

        if err.new_record?
          err.assign_attributes(detection_date: DateTime.current, value_type: "",
            account_path: @customer.path, details: schematize(@error))
        else
          err.assign_attributes(detection_date: DateTime.current)
        end

        err.save
      end

      private

      def schematize(raw_json)
        return {} if raw_json.nil?

        parsed = { "type" => "SentineloneError" }
        parsed["attributes"] = raw_json

        parsed
      end
    end
  end
end
