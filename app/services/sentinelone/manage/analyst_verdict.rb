# :nodoc
module Sentinelone
  # :nodoc
  module Manage
    # :nodoc
    class AnalystVerdict
      ANALYST_VERDICT_URL = "/web/api/v2.1/threats/analyst-verdict".freeze

      def initialize(app_result_ids, new_value)
        @new_value = new_value
        @result_ids = app_result_ids
        @app_results = Apps::Result.where(id: app_result_ids)
        @credential = credential
      end

      def call
        return if @new_value.blank?

        if @app_results.blank? || @credential.nil?
          # error_message = "S1 - AnalystVerdict - result: #{@result_ids&.join(', ')}"
          # Rails.logger.warn(error_message)
          return
        end

        response = update_value

        # otherwise, we're good to go
        if response.code == "200"
          @app_results.each do |app_result|
            details = app_result["details"]
            details["attributes"]["analystVerdict"] = @new_value
            app_result.assign_attributes(details: details)
            raise Exception("S1 - AnalystVerdict - Save fail - #{app_result&.id}") unless app_result.save
          end
        else
          Rails.logger.error(
            "S1 - AnalystVerdict - result: #{@result_ids.join(', ')}, error: #{response.body}"
          )
        end
      end

      private

      def credential
        @app_results.each do |ar|
          return ar.credential if ar.credential.present?
        end
        nil
      end

      def update_value
        # I don't know why it isn't working with HTTPI
        # Putting these exact fields into HTTPI fails and this works correctly so...
        url = "#{@credential.sentinelone_url}#{ANALYST_VERDICT_URL}"
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
        ids = @app_results.collect { |ar| ar&.details&.id }.compact
        {
          "filter" => { "ids" => ids },
          "data"   => { "analystVerdict" => @new_value }
        }
      end
    end
  end
end
