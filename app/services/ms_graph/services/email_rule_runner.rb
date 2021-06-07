# :nodoc
module MsGraph
  # :nodoc
  module Services
    # :nodoc
    class EmailRuleRunner
      include ErrorHelper

      BASE_URL = "https://graph.microsoft.com/v1.0/users".freeze
      END_URL = "mailFolders/inbox/messageRules".freeze

      def initialize(credential_id)
        @cred = Credential.find(credential_id)
        @app_id = App.where(report_template: "directory_audit").first.id
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        return if @cred.nil? || @app_id.nil?
        return unless PIPELINE_TRIALS.include?(-1)

        @cred.account.all_descendant_billable_instances.office_365_mailbox.where(active: true)
             .each do |o365_account|
          pull_rules(o365_account.external_id) unless o365_account.external_id.include?("#EXT#")
        end
      end

      private

      def api_token
        @api_token ||= ::MsGraph::CredentialUpdater.new.call(@cred)
      end

      def headers
        @headers ||= { Authorization: "Bearer #{api_token}" }
      end

      def make_api_call(user)
        request = HTTPI::Request.new
        request.url = "#{BASE_URL}/#{user}/#{END_URL}"
        request.headers = headers

        HTTPI.get(request)
      end

      def pull_rules(user_id)
        resp = make_api_call(user_id)
        return if html_error(__FILE__, resp)

        process(resp, user_id)
      end

      def process(resp, user_id)
        temp = JSON.parse(resp.raw_body)

        # if temp.include?("@odata.nextLink")
        #   ServiceRunnerJob.perform_later("MsGraph::Services::EmailRules",
        #                                  @cred.id, temp["@odata.nextLink"])
        # end
        return if temp.dig("value").blank?

        ServiceRunnerJob.set(queue: :utility).perform_later(
          "MsGraph::SaveTemplates::EmailRules",
          @app_id, @cred.id, @cred.customer, temp.dig("value"), user_id
        )
        true
      end
    end
  end
end
