module Api
  module V1
    module Integrations
      # API endpoint allowing for moving an MSP to under another account
      # Originally set up to move an existing provider under Pax8
      class MovePartnerController < Api::V1::Integrations::Pax8BaseController
        # by extending Pax8BaseController, these all have "authenticate" as a before_action

        def create
          if valid_target && valid_code && (valid_code&.expiration || 1.day.ago) > DateTime.current
            ServiceRunnerJob.perform_later("Providers::Move", valid_code.account_id, params[:target_account])
            render json: response_json
          else
            render json: { error: "invalid parameters" }, status: :not_found
          end
        end

        private

        def valid_target
          !params[:target_account].nil?
        end

        def valid_code
          @valid_code ||= MoveCode.find_by(id: params[:move_code])
        end

        def response_json
          {
            response:    "success",
            id:          valid_code.account_id,
            last_billed: valid_code.account.charges.order(:end_date).last&.end_date
          }.to_json
        end
      end
    end
  end
end
