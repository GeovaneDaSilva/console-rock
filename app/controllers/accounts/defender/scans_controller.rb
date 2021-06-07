module Accounts
  module Defender
    # Account scoped defender scans
    class ScansController < AuthenticatedController
      def create
        authorize current_account, :defender_action?
        account_broadcast!

        flash[:notice] = "Requested agents initiate a Windows Defender #{scan_type.humanize} Scan"

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
          type:    "defender_scan",
          payload: {
            scan_type: scan_type
          }
        }
      end

      def scan_type
        case params[:scan_type]
        when "quick"
          "quick"
        when "full"
          "full"
        end
      end
    end
  end
end
