module Apps
  module Results
    # Process an app result
    class Processor
      include ProcessorNotifications

      def initialize(app_result)
        @app_result = app_result
        @account = Account.find(app_result&.customer_id)
        @account_app = AccountApp.where(account: @account.self_and_all_ancestors).enabled
                                 .joins(:account).order("accounts.path ASC").first
      rescue NoMethodError
        # This most likely happened because you are trying to process an app result associated with a
        # provider rather than with a customer.  We do not support this.
        Rails.logger.error("Processor error for app result #{app_result.id},"\
          " with account #{@account}")
      end

      def call
        return if @account.nil?

        ServiceRunnerJob.perform_later("Pipeline::Start", { result_id: @app_result.id }) if @account.managed?

        # notify_subscriptions!
      end
    end
  end
end
