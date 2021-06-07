# :nodoc
module Sentinelone
  # :nodoc
  module Manage
    # :nodoc
    class Whitelist
      ADD_TO_EXCLUSIONS_URL = "/web/api/v2.1/threats/add-to-exclusions".freeze

      def initialize(app_result_id, file_hash)
        @file_hash = file_hash
        @result_id = app_result_id
        @app_result = Apps::Result.find_by(id: app_result_id)
        @credential = @app_result&.credential
      end

      def call
        return if @file_hash.blank?

        if @app_result.nil? || @credential.nil?
          # error = "S1 - Whitelisting - result: #{@result_id}, cred: #{@app_result&.credential_id}"
          # Rails.logger.warn(error)
          return
        end

        response = update_value

        if response.code == "200"
          @app_result.destroy
        else
          Rails.logger.error("S1 - Whitelisting - result: #{@app_result&.id}, error: #{response.body}")
        end
      end

      private

      def update_value
        # I don't know why it isn't working with HTTPI
        # Putting these exact fields into HTTPI fails and this works correctly so...
        url = "#{@credential.sentinelone_url}#{ADD_TO_EXCLUSIONS_URL}"
        uri = URI.parse(url)
        request = Net::HTTP::Post.new(uri)
        request.content_type = "application/json"
        request["Authorization"] = "ApiToken #{@credential.access_token}"
        request.body = JSON.dump(body)
        req_options = { use_ssl: uri.scheme == "https" }

        resp = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end

        resp
      end

      def body
        {
          "data"   => {
            "mode"        => "suppress",
            "type"        => "hash",
            "targetScope" => "group"
          },
          "filter" => {
            "contentHashes" => @file_hash
          }
        }
      end
    end
  end
end
