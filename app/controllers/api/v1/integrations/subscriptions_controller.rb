module Api
  module V1
    module Integrations
      # API endpoint allowing for CRUD (not delete yet) operations on Pax8 subscriptions
      class SubscriptionsController < Api::V1::Integrations::Pax8BaseController
        # by extending Pax8BaseController, these all have "authenticate" as a before_action

        def create
          if bulk_suspend && bulk_cancel && bulk_reactivate
            head :ok
          else
            render json: { error: "problem saving updates" }.to_json, status: :internal_server_error
          end
        end

        private

        def bulk_suspend
          return true unless params[:suspend]

          change_sub_accounts(params[:suspend], { paid_thru: 1.day.ago, status: :suspended })
          update_other_applications(params[:suspend], false)
        end

        def bulk_cancel
          return true unless params[:cancel]

          change_sub_accounts(params[:cancel], { paid_thru: 1.day.ago, status: :canceled })
          update_other_applications(params[:cancel], false)
        end

        def bulk_reactivate
          return true unless params[:reactivate]

          change_sub_accounts(params[:reactivate], { paid_thru: account.paid_thru, status: :active })
          update_other_applications(params[:reactivate], true)
        end

        def change_sub_accounts(ids, new_params)
          ids.each do |id|
            acc = Account.find_by(id: id)
            acc.all_descendants.where(plan_id: nil).update_all(new_params)
            acc.update(new_params)
          end
        end

        def update_other_applications(accounts, paid)
          accounts.each do |account_id|
            acc = Account.find_by(id: account_id)
            ServiceRunnerJob.perform_later("OtherApps::UpdateBillingStatus", acc, paid)
          end
        end
      end
    end
  end
end
