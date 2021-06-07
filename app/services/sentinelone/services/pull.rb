# :nodoc
module Sentinelone
  # :nodoc
  module Services
    # :nodoc
    class Pull
      include PostApiCallProcessor

      def initialize(cred, type, params = {})
        # base = "https://usea1-pax8.sentinelone.net".freeze
        base = cred&.sentinelone_url if cred.is_a?(Credential)
        look = {
          "threats"        => { url: "/web/api/v2.0/threats", method: "get", wait: 65.minutes },
          "user_info"      => { url: "/web/api/v2.0/private/my-user", method: "get" },
          "device_info"    => { url: "/web/api/v2.0/private/navigation/totals", method: "get" },
          "api_token_info" => { url: "/web/api/v2.0/users/api-token-details", method: "post" },
          "companies"      => { url: "/web/api/v2.0/sites", method: "get" }
        }
        @cred = cred
        @type = type
        @params = params
        @query = params.except(:once_only)
        @url = "#{base}#{look.dig(type, :url)}"
        @method = look.dig(type, :method)
        @wait = look.dig(type, :wait) || 24.hours
      end

      def call
        return if @type.nil? || @cred.nil? || @method.nil? || @url.nil?
        return if !@cred.instance_of?(Credentials::Sentinelone)
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current

        events
        schedule_next
      end

      private

      def make_api_call(token)
        headers = {
          Authorization: "ApiToken #{token}"
        }
        request = HTTPI::Request.new
        request.url = @url
        request.headers = headers
        request.query = @query

        if @method == "get"
          HTTPI.get(request)
        elsif @method == "put"
          HTTPI.put(request)
        elsif @method == "post"
          HTTPI.post(request)
        end
      end

      def events
        @query["limit"] = 500 if @type == "threats" && @query["limit"].nil?
        # @query["updatedAt__gt"] = last_pull_time unless last_pull_time.nil?

        resp = make_api_call @cred.access_token
        credential_is_working(resp)

        unless resp.code == 200
          body = nil
          begin
            body = JSON.parse(resp.raw_body)
          rescue JSON::ParserError
            body = resp.raw_body
          end

          Rails.logger.error("SentinelOne pull error.  Code #{resp.code} with message #{body}")
          ServiceRunnerJob.set(queue: :utility).perform_later(
            "Sentinelone::Services::PullError", body, nil, @cred
          ) # figure out if I want to add something that puts this in the "right" app.
          # right now there is only one SentinelOne app, so it doesn't matter
          return
        end

        process(resp)
      end

      def process(resp)
        temp = JSON.parse(resp.raw_body)
        unless temp.dig("pagination", "nextCursor").nil?
          ServiceRunnerJob
            .set(queue: :utility)
            .perform_later(
              "Sentinelone::Services::Pull", @cred, @type,
              {
                "cursor":  temp.dig("pagination", "nextCursor"),
                once_only: true
              }
            )
        end
        return if temp.dig("data").nil?

        ServiceRunnerJob.set(queue: :utility).perform_later(
          "Sentinelone::SaveTemplates::#{@type.camelize}",
          nil, @cred, temp.dig("data")
        )
      end

      def schedule_next
        # ** need to change this to use schedule_next / just put that in the original method
        return unless @type == "device_info"
        return if @params[:once_only]

        # params = { "updatedAt__gt": 7.days.ago.utc.iso8601 } if @type == "threats"
        ServiceRunnerJob
          .set(wait: @wait, queue: :utility)
          .perform_later("Sentinelone::Services::Pull", @cred, @type, params)
      end
    end
  end
end
