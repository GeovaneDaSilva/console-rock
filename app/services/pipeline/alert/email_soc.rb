module Pipeline
  module Alert
    # nodoc
    class EmailSoc
      def initialize(message, rule_id, app_result_id, _template_id, _reset_time, _fields)
        @message = message
        @app_result = ::Apps::Result.find(app_result_id)
        @rule = LogicRule.find(rule_id)
      rescue ActiveRecord::RecordNotFound
        @app_result = nil
        Rails.logger.error("Failed to email SOC for rule #{rule_id} and app result #{app_result_id}")
      end

      def call
        return if @app_result.nil?

        customer = @app_result.customer.nil? ? Account.find(@app_result.customer_id) : @app_result.customer

        NotificationMailer.soc_rule(customer, @app_result, @rule).deliver_later

        # +++ eventually what is needed is a different dashboard for important things
        #   (i.e. things that have tripped a SOMETHING)
        #
        # 1) they take care of anything on the important dashboard
        #   (should be the default login page for anyone with a SOC-OPERATOR role)
        # 2) They look through the other things to make new rules
      end
    end
  end
end
