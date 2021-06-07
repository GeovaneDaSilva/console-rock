# :nodoc
module Bitdefender
  # :nodoc
  module Services
    # :nodoc
    class Pull
      include PostApiCallProcessor

      def initialize(cred, type, params = {})
        base = cred&.bitdefender_url if cred.is_a?(Credential)
        @cred = cred
        @type = type
        @params = params
        @url = "#{base}#{look.dig(type, :url)}"
        @method = look.dig(type, :method)
        @wait = rand(60..120).minutes
      end

      def look
        @look ||= {
          "quarantine_computers" => {
            url: "/v1.0/jsonrpc/quarantine/computers", method: "post", command: "getQuarantineItemsList",
            pull_type: "quarantine", type: "computers"
          },
          "quarantine_exchange"  => {
            url: "/v1.0/jsonrpc/quarantine/exchange", method: "post", command: "getQuarantineItemsList",
            pull_type: "quarantine", type: "exchange"
          },
          "incident"             => {
            url: "/v1.0/jsonrpc/incidents", method: "post", command: "getBlocklistItems",
            pull_type: "incident"
          }
        }
      end

      def call
        return if @type.nil? || @cred.nil? || @method.nil?
        return if !@cred.instance_of?(Credentials::Bitdefender)
        return if @cred.account.billing_account.paid_thru < DateTime.current
        return if PIPELINE_TRIALS.include?(@cred.account.id)

        events
      end

      private

      def make_api_call(token)
        base_64_token = Base64.encode64("#{token}:").delete("\n")
        headers = {
          "Content-Type"  => "application/json",
          "Authorization" => "Basic #{base_64_token}"
        }

        request = HTTPI::Request.new
        request.url = @url
        request.headers = headers
        request.query = @params
        request.body = {
          "id": SecureRandom.uuid, "jsonrpc": "2.0",
          "method": look.dig(@type, :command), "params": []
        }.to_json
        if @method == "get"
          HTTPI.get(request)
        elsif @method == "put"
          HTTPI.put(request)
        elsif @method == "post"
          HTTPI.post(request)
        end
      end

      def events
        resp = make_api_call @cred.access_token
        credential_is_working(resp)

        temp = JSON.parse(resp.raw_body)
        result = temp.dig("result")

        process(result)

        continue_processing(result)
        # success = continue_processing(result)

        # schedule_next if success
      end

      def process(result)
        events = result&.dig("items")

        return if events.nil?

        args = ["Bitdefender::SaveTemplates::#{look.dig(@type, :pull_type).camelize}",
                nil, @cred, events]
        args << look.dig(@type, :type) if look.dig(@type, :pull_type) == "quarantine"
        ServiceRunnerJob.set(queue: :utility).perform_later(*args)
      end

      def continue_processing(result)
        if (result&.dig("pagesCount") || 0) > (result&.dig("page") || 0)
          ServiceRunnerJob
            .set(queue: :utility)
            .perform_later(
              "Bitdefender::Services::Pull", @cred, @type,
              @params.merge({ "page": result.dig("page") + 1 })
            )
          false
        else
          true
        end
      end

      # def schedule_next
      #   ServiceRunnerJob
      #     .set(wait: @wait, queue: :utility)
      #     .perform_later("Bitdefender::Services::Pull", @cred, @type)
      # end
    end
  end
end
