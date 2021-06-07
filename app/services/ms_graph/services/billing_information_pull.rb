# :nodoc
module MsGraph
  # :nodoc
  module Services
    # :nodoc
    class BillingInformationPull
      def initialize(credential_id, url = nil)
        @cred = Credential.find(credential_id)
        @url = url || "https://graph.microsoft.com/v1.0/users"
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        return if @cred.nil?

        ms_graph_events

        ServiceRunnerJob.perform_later("MsGraph::Services::MfaEnabledUsers", @cred.id)
      end

      private

      def make_api_call(token, query = nil)
        headers = {
          Authorization: "Bearer #{token}"
        }
        request = HTTPI::Request.new
        request.url = @url
        request.headers = headers
        request.query = query if @url == "https://graph.microsoft.com/v1.0/users"

        HTTPI.get(request)
      end

      def ms_graph_events
        token = MsGraph::CredentialUpdater.new.call(@cred)

        query = {}
        if @url == "https://graph.microsoft.com/v1.0/users"
          query = { "$select": "userPrincipalName, assignedLicenses, id, displayName" }
        end

        resp = make_api_call token, query

        unless resp.code == 200
          begin
            Rails.logger.error("(Billing) MS Graph API failure code #{resp.code}
              with message #{JSON.parse(resp.raw_body)}")
            return
          rescue JSON::ParserError
            Rails.logger.error("(Billing) MS Graph API failure code #{resp.code}
              with message #{resp.raw_body}")
            return
          end
        end

        temp = JSON.parse(resp.raw_body)
        if temp.include?("@odata.nextLink")
          ServiceRunnerJob.perform_later("MsGraph::Services::BillingInformationPull",
                                         @cred.id, temp["@odata.nextLink"])
        end
        ServiceRunnerJob.perform_later("MsGraph::Services::BillingInformationProcess",
                                       @cred.id, temp["value"])
      end
    end
  end
end
