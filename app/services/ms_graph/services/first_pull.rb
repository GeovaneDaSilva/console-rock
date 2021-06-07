# :nodoc
module MsGraph
  # :nodoc
  module Services
    # :nodoc
    class FirstPull
      def initialize(credential_id)
        @cred = Credential.find(credential_id)
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        return if @cred.nil?
        return if @cred.customer.billing_account.actionable_past_due?

        Apps::Office365App.find_each do |app|
          account_apps = AccountApp.where(account_id: @cred.customer.self_and_all_ancestors,
            disabled_at: nil, app_id: app.id).where.not(enabled_at: nil).order(:last_pull, :account_id)
          next if account_apps.blank?

          if account_apps.where(account_id: @cred.customer_id).blank?
            account = account_apps.last.dup
            if account.update(account_id: @cred.customer_id)
              ServiceRunnerJob.perform_later("MsGraph::DataUpdater", app.id, @cred.id, account.id)
            else
              Rails.logger.error(
                "Failed to create new AccountApp for cred #{cred.id}, app #{@app.title}"
              )
            end
          else
            ServiceRunnerJob.perform_later("MsGraph::DataUpdater", app.id, @cred.id,
                                           account_apps.where(account_id: @cred.customer_id).first.id, true)
          end
        end

        ServiceRunnerJob.perform_later("MsGraph::Services::BillingInformationPull", @cred.id)
        ServiceRunnerJob.perform_later("MsGraph::Services::PullDomains", @cred)
      end
    end
  end
end
