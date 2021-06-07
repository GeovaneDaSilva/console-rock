module Accounts
  module Defender
    # Account scoped defender update
    class UpdatesController < AuthenticatedController
      def create
        authorize current_account, :defender_action?
        account_broadcast!

        flash[:notice] = "Requested agents update Windows Defender Signatures"

        respond_to do |format|
          format.html do
            redirect_to account_defender_path(current_account)
          end

          format.js
        end
      end

      private

      def account_broadcast!
        ServiceRunnerJob.perform_later(
          "DeviceBroadcasts::Account",
          current_account,
          broadcast_message.to_json
        )
      end

      def broadcast_message
        {
          type:    "defender_signature_update",
          payload: {}
        }
      end
    end
  end
end
