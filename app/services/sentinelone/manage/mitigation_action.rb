# :nodoc
module Sentinelone
  # :nodoc
  module Manage
    # :nodoc
    class MitigationAction
      ANALYST_VERDICT_URL = "/web/api/v2.1/threats/mitigate/".freeze

      def initialize(app_result_id, action)
        @action = action
        @result_id = app_result_id
        @app_result = Apps::Result.find_by(id: app_result_id)
        @credential = @app_result&.credential
      end

      def call
        return if @action.blank?

        if @app_result.nil? || @credential.nil?
          # error = "S1 - MitigationAction - result: #{@result_id}, cred: #{@app_result&.credential_id}"
          # Rails.logger.warn(error)
          return
        end

        response = update_value
        # otherwise, we're good to go
        if response.code == "200"
          details = @app_result["details"]
          details["attributes"]["mitigationReport"][@action] = { status: "success" }
          raise Exception("S1 - MitigationAction - Save fail - #{@app_result&.id}") unless @app_result.save
        else
          Rails.logger.error("S1 - MitigationAction - result: #{@app_result&.id}, error: #{response.body}")
        end
      end

      private

      # TODO: this API is clearly designed to do these in bulk.
      def update_value
        # I don't know why it isn't working with HTTPI
        # Putting these exact fields into HTTPI fails and this works correctly so...
        url = "#{@credential.sentinelone_url}#{ANALYST_VERDICT_URL}#{@action}"
        uri = URI.parse(url)
        request = Net::HTTP::Post.new(uri)
        request.content_type = "application/json"
        request["Authorization"] = "ApiToken #{@credential.access_token}"
        body = { "filter" => { "ids" => [@app_result.details.id] } }
        request.body = JSON.dump(body)
        req_options = { use_ssl: uri.scheme == "https" }

        resp = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end

        resp
      end
    end
  end
end
