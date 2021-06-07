# :nodoc
module DnsFilter
  # :nodoc
  module Services
    # :nodoc
    class PullQueryLogs
      include PostApiCallProcessor
      URL = "https://api.dnsfilter.com/v1/traffic_reports/query_logs".freeze

      DEFAULT_WAIT = 24.hours.freeze

      def initialize(credential, options = {})
        @credential = credential
        @options    = options
      end

      def call
        return if @credential.nil? || !@credential.instance_of?(Credentials::DnsFilter)
        return if @credential.account.billing_account.paid_thru < DateTime.current

        authenticate

        data = av_customer_maps.map do |customer_map|
          account_id      = customer_map.account_id
          antivirus_id    = customer_map.antivirus_id
          organization_id = @credential.organizations.dig(antivirus_id)
          [account_id, make_api_call(organization_id)]
        end.to_h

        persist(data.to_json)

        schedule_next
      end

      private

      def app_id
        @app_id ||= Apps::DnsFilterApp.first.id
      end

      def av_customer_maps
        AntivirusCustomerMap.where(app_id: app_id)
      end

      def authenticate
        DnsFilter::Services::Authenticate.new(@credential).call
      end

      def make_api_call(organization_id, page = 1)
        headers = { Authorization: "Bearer #{@credential.access_token}" }

        request = HTTPI::Request.new
        request.url = URL
        request.headers = headers
        request.query = build_query(organization_id, page)
        response = HTTPI.get(request)

        credential_is_working(response)
        body = parse_json(response.raw_body)

        unless response.code == 200
          Rails.logger.error("DNSFilter pull query logs error. Code #{response.code} with message #{body}")
          return
        end

        values = body["data"]["values"]
        if page < body["data"]["page"]["total"]
          values + make_api_call(organization_id, page + 1)
        else
          values
        end
      rescue Errno::ECONNRESET
        raise DnsFilter::ConnectionPeerResetError
      end

      def persist(data)
        ServiceRunnerJob
          .set(queue: :utility)
          .perform_later("DnsFilter::SaveTemplates::QueryLogs", app_id, @credential, data)
      end

      def schedule_next
        wait = @options.fetch(:wait, DEFAULT_WAIT)
        ServiceRunnerJob
          .set(wait: wait, queue: :utility)
          .perform_later("DnsFilter::Services::PullQueryLogs", @credential)
      end

      def build_query(organization_id, page)
        page_query = page > 1 ? { "page[number]" => page } : {}

        time_range = @options.dig(:time_range)
        time_range_query = {}

        if time_range
          thru_date = Time.zone.now
          from_date = thru_date - time_range.hours
          time_range_query = { from: from_date.iso8601, to: thru_date.iso8601 }
        end

        { user_id: @credential.dns_filter_user_id, organization_id: organization_id }
          .merge(page_query)
          .merge(time_range_query)
      end

      def parse_json(text)
        JSON.parse(text)
      rescue JSON::ParserError
        text
      end
    end
  end
end
