# :nodoc
module MsGraph
  # :nodoc
  module Services
    # :nodoc
    class MakeRefSecureScore
      def initialize(cred, id)
        @cred = Credentials::MsGraph.find(cred)
        @id = id
        @url = "https://graph.microsoft.com/v1.0/security/secureScoreControlProfiles/#{id}"
      end

      def call
        return if @id.nil?
        return unless RefSecureScore.where(id: @id).empty?

        new_record = make_api_call
        return if new_record.blank?

        RefSecureScore.new(id: new_record["id"], scored: true, deprecated: false,
          max_score: new_record["maxScore"], details: new_record.except("@odata.context")).save
      end

      private

      def make_api_call
        headers = {
          Authorization: "Bearer #{@cred.access_token}"
        }

        request = HTTPI::Request.new
        request.url = @url
        request.headers = headers

        begin
          resp = HTTPI.get(request)
        rescue Errno::ECONNRESET
          raise MsGraph::ConnectionPeerResetError
        end

        unless resp.code == 200
          Rails.logger.error(
            "MS Graph Secure Score Template API failure code #{resp.code} with message"\
            " #{JSON.parse(resp.raw_body)}"
          )
          return []
        end

        JSON.parse(resp.raw_body) || []
      end
    end
  end
end
