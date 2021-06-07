# :nodoc
module Sentinelone
  # :nodoc
  module Services
    # Sentinelone schedules the next pull on successful execution of a save template
    # This means all future pulls can be stopped by killing the current job, which happens
    #
    # So this should be run as needed to re-enqueue jobs that were erroneously stopped
    #
    # NOTE - this loops through all customers (potentially), and should be run at a non-peak time
    class JobRestarter
      def initialize
        temp = App.where(report_template: "sentinelone").first
        @app_id = temp.nil? ? nil : temp.id
      end

      def call
        return if @app_id.nil?

        # TODO: Find some way to spread out the cost(?)
        account_apps.each do |acc_app|
          account = Account.find(acc_app.account_id)

          customer_list = account.customer? ? [account] : account.all_descendant_customers

          customer_list.each do |customer|
            # check if they are delinquent
            next if customer.billing_account.actionable_past_due?

            cred = Credentials::Sentinelone.where(customer_id: customer.id).first
            next if cred.nil?

            ServiceRunnerJob.set(wait: rand(1..120).minutes)
                            .perform_later("Sentinelone::Services::Pull", cred, "threats")
          end
        end
      end

      private

      def account_apps
        @account_apps ||= AccountApp.where(disabled_at: nil, app_id: @app_id).where.not(enabled_at: nil)
                                    .order(:account_id)
      end
    end
  end
end
