# :nodoc
module MsGraph
  # :nodoc
  module Services
    # :nodoc
    class MsPullError
      def initialize(error, app_id, cred)
        @error = error
        @app_id = app_id || Apps::Office365App.first.id
        @customer_id = cred.customer_id
      end

      def call
        error_message = nil
        if @error.dig("error").class == Hash
          error_message = @error.dig("error", "code")
        elsif !@error.dig("error").nil?
          error_message = @error.dig("error")
        end

        return if error_message.nil?

        err = Apps::Office365Result.where(app_id: @app_id, customer_id: @customer_id, verdict: "malicious",
          value: error_message).first_or_create

        if err.new_record?
          err.assign_attributes(detection_date: DateTime.current, value_type: "",
            account_path: Customer.find(@customer_id).path, details: schematize(@error))
        else
          err.assign_attributes(detection_date: DateTime.current)
        end

        err.save # is there any point to checking whether this succeeded?
      end

      private

      def schematize(raw_json)
        return {} if raw_json.nil?

        parsed = { "type" => "MsGraphError" }
        parsed["attributes"] = if raw_json.dig("error").class == Hash
                                 raw_json.dig("error")
                               else
                                 raw_json
                               end

        parsed
      end
    end
  end
end
