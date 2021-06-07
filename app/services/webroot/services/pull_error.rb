# :nodoc
module Webroot
  # :nodoc
  module Services
    # :nodoc
    class PullError
      def initialize(error, app_id, cred)
        @error = error
        @app_id = app_id || Apps::WebrootApp.first.id
        @customer = cred.account
      end

      def call
        error_message = nil
        if @error.dig("errors").class == Array
          error_message = @error.dig("errors").first.dig("detail")
        elsif !@error.dig("errors").nil? # this is probably not going to happen
          # (assuming Webroot has more consistent error messages than MS)
          error_message = @error.dig("errors")
        end

        return if error_message.nil?

        err = Apps::WebrootResult.where(app_id: @app_id, customer_id: @customer.id, verdict: "malicious",
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

        parsed = { "type" => "WebrootError" }
        parsed["attributes"] = raw_json

        parsed
      end
    end
  end
end
