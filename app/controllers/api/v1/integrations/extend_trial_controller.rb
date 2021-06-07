module Api
  module V1
    module Integrations
      # API endpoint allowing for moving an MSP to under another account
      # Originally set up to move an existing provider under Pax8
      class ExtendTrialController < Api::V1::Integrations::Pax8BaseController
        # by extending Pax8BaseController, these all have "authenticate" as a before_action
        MAX_ALLOWED_TRIAL = 35

        def create
          if target.present?
            if allowed_extension
              if target.update(paid_thru: new_paid_thru)
                render json: { account_id: target.id, paid_thru: target.paid_thru }
              else
                render json: { error: "error saving record" }, status: :internal_server_error
              end
            else
              render json: { error: "invalid extension" }, status: :not_found
            end
          else
            render json: { error: "invalid account" }, status: :not_found
          end
        end

        private

        def target
          @target ||= account.self_and_all_descendants.find_by(id: params[:account_id])
        end

        def new_paid_thru
          @new_paid_thru ||= @target.paid_thru + params[:days_to_extend_trial].to_i.days
        end

        def allowed_extension
          new_paid_thru < @target.created_at + MAX_ALLOWED_TRIAL.days
        end
      end
    end
  end
end
