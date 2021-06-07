# :nodoc
module MsGraph
  # :nodoc
  class Scheduler
    def initialize(app_name)
      @app = App.where(report_template: app_name).first
    end

    def call
      Credentials::MsGraph.find_each do |cred|
        wait = rand(0..59).minutes + rand(0..59).seconds
        next if cred.customer.billing_account.paid_thru < DateTime.current

        account_apps = AccountApp.where(account_id: cred.customer.self_and_all_ancestors, disabled_at: nil,
          app: @app).where.not(enabled_at: nil).order(:last_pull, :account_id)
        next if account_apps.blank?

        if account_apps.where(account_id: cred.customer_id).blank?
          account = account_apps.last.dup
          if account.update(account_id: cred.customer_id)
            ServiceRunnerJob.set(wait: wait)
                            .perform_later("MsGraph::DataUpdater", @app.id, cred.id, account.id)
          else
            Rails.logger.error(
              "MsGraph::Scheduler failed to create new AccountApp for cred #{cred.id}, app #{@app.title}"
            )
          end
        else
          ServiceRunnerJob.set(wait: wait).perform_later(
            "MsGraph::DataUpdater", @app.id, cred.id,
            account_apps.where(account_id: cred.customer_id).first.id
          )
        end
      end
    end
  end
end
