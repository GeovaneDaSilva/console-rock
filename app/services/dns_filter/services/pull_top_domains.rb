# :nodoc
module DnsFilter
  # :nodoc
  module Services
    # :nodoc
    class PullTopDomains
      include PostApiCallProcessor
      URL = "https://api.dnsfilter.com/v1/traffic_reports/top_domains".freeze

      DEFAULT_WAIT = 3
      DEFAULT_FROM = 24

      def initialize(credential, options = {})
        @credential = credential
        @options    = options
        @page       = options[:page] || 1
        @first_pull = options[:first_pull] || false
      end

      def call
        return if @credential.nil? || !@credential.instance_of?(Credentials::DnsFilter)
        return if @credential.account.billing_account.paid_thru < DateTime.current

        authenticate

        data = av_customer_maps.map do |customer_map|
          account_id      = customer_map.account_id
          antivirus_id    = customer_map.antivirus_id
          [account_id, make_api_call(antivirus_id, @page)]
        end.to_h

        data.merge!(integration_success_message) if @first_pull

        persist(data.to_json)

        schedule_next if @options[:page].nil?
        data
      end

      private

      def integration_success_message
        { @credential.account_id => [{ "domain"         => "sample data",
                                       "policies_names" => ["Integration Successful"],
                                       "networks_names" => ["Integration Successful"],
                                       "users_names"    => [@credential.account.name],
                                       "methods_names"  => ["Integration Successful"] }] }
      end

      def app_id
        @app_id ||= Apps::DnsFilterApp.first.id
      end

      def av_customer_maps
        account_ids = @credential.account.self_and_all_descendants.pluck(:id)
        AntivirusCustomerMap.where(app_id: app_id, account_id: account_ids)
      end

      def authenticate
        DnsFilter::Services::Authenticate.new(@credential).call
      end

      # rubocop: disable Metrics/MethodLength
      def make_api_call(organization_id, page)
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

        values = body.dig("data", "values")
        if page < body.dig("data", "page", "total")
          ServiceRunnerJob.set(wait: wait, queue: :utility)
                          .perform_later("DnsFilter::Services::PullTopDomains",
                                         @credential, { page: body.dig("data", "page", "next") })
        end
        values
      rescue Errno::ECONNRESET
        raise DnsFilter::ConnectionPeerResetError
      end
      # rubocop: enable Metrics/MethodLength

      def persist(data)
        ServiceRunnerJob
          .set(queue: :utility)
          .perform_later("DnsFilter::SaveTemplates::TopDomains", app_id, @credential, data)
      end

      def from
        Time.at(@options.fetch(:from, DEFAULT_FROM.hours.ago.to_i)).utc.iso8601
      end

      def wait
        @options.fetch(:wait, DEFAULT_WAIT.hours)
      end

      def schedule_next
        return unless PIPELINE_TRIALS.include?(-1)

        ServiceRunnerJob
          .set(wait: wait, queue: :utility)
          .perform_later("DnsFilter::Services::PullTopDomains", @credential)
      end

      def build_query(organization_id, page)
        page_query = page > 1 ? { "page[number]" => page } : {}

        { organization_ids: organization_id,
          security_report:  true,
          from:             from }
          .merge(page_query)
      end

      def parse_json(text)
        JSON.parse(text)
      rescue JSON::ParserError
        text
      end
    end
  end
end
