# :nodoc
module Sophos
  # :nodoc
  module Services
    # :nodoc
    class PullAlerts
      include ErrorHelper
      include PostApiCallProcessor

      DEFAULT_WAIT = (55..75).freeze

      def initialize(credential, options = {})
        @credential = credential
        @options    = options
      end

      def call
        return if @credential.nil? || !@credential.instance_of?(Credentials::Sophos)
        return if @credential.account.billing_account.paid_thru < DateTime.current

        authenticate

        data = av_customer_maps.map do |customer_map|
          account_id   = customer_map.account_id
          antivirus_id = customer_map.antivirus_id
          api_host     = @credential.tenants&.dig(antivirus_id, "apiHost")
          [account_id, make_api_call(antivirus_id, api_host)]
        end.to_h

        persist(data.to_json)

        schedule_next
      end

      private

      def app_id
        @app_id ||= Apps::SophosApp.first.id
      end

      def av_customer_maps
        AntivirusCustomerMap.where(app_id: app_id)
      end

      def authenticate
        Sophos::Services::Authenticate.new(@credential).call
      end

      def make_api_call(tenant_id, base_url, page = 1, next_page_key = nil)
        return if tenant_id.blank? || base_url.blank?

        request = HTTPI::Request.new
        request.url = build_url(base_url)
        request.headers = build_headers(tenant_id)
        request.query = build_query(next_page_key)
        response = HTTPI.get(request)
        credential_is_working(response)

        body = parse_json(response.raw_body)

        unless response.code == 200
          Rails.logger.error("Sophos pull alerts error. Code #{response.code} with message #{body}")
          return
        end

        items = body["items"]
        if page < body["pages"]["total"]
          items + make_api_call(tenant_id, base_url, page + 1, body["pages"]["nextKey"])
        else
          items
        end
      rescue Errno::ECONNRESET
        raise Sophos::ConnectionPeerResetError
      end

      def persist(data)
        ServiceRunnerJob
          .set(queue: :utility)
          .perform_later("Sophos::SaveTemplates::Alerts", app_id, @credential, data)
      end

      def schedule_next
        return unless PIPELINE_TRIALS.include?(-1)

        wait = @options.fetch(:wait, rand(DEFAULT_WAIT).minutes)
        ServiceRunnerJob
          .set(wait: wait, queue: :utility)
          .perform_later("Sophos::Services::PullAlerts", @credential)
      end

      def build_url(base_url)
        base_url + "/common/v1/alerts"
      end

      def build_headers(tenant_id)
        { Authorization: "Bearer #{@credential.access_token}" }.merge("X-Tenant-ID" => tenant_id)
      end

      def build_query(next_page_key)
        page_query = next_page_key ? { "pageFromKey" => next_page_key } : {}
        { "pageTotal" => true }.merge(page_query)
      end

      def parse_json(text)
        JSON.parse(text)
      rescue JSON::ParserError
        text
      end
    end
  end
end
