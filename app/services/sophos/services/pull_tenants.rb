# :nodoc
module Sophos
  # :nodoc
  module Services
    # :nodoc
    class PullTenants
      include ErrorHelper
      include PostApiCallProcessor

      URL_LOOKUP = {
        partner:      "https://api.central.sophos.com/partner/v1/tenants",
        organization: "https://api.central.sophos.com/organization/v1/tenants"
      }.freeze

      DEFAULT_WAIT = 24.hours.freeze

      def initialize(credential, options = {})
        @credential = credential
        @options    = options
      end

      def call
        return if @credential.nil? || !@credential.instance_of?(Credentials::Sophos)

        authenticate

        data = make_api_call
        persist(data.to_json)

        schedule_next
      end

      private

      def organization_id
        @organization_id ||= @credential.organization_id
      end

      def partner_id
        @partner_id ||= @credential.partner_id
      end

      def authenticate
        Sophos::Services::Authenticate.new(@credential).call
      end

      def make_api_call(page = 1)
        request = HTTPI::Request.new
        request.url = url
        request.headers = build_headers
        request.query = build_query(page)
        response = HTTPI.get(request)
        credential_is_working(response)

        body = parse_json(response.raw_body)

        unless response.code == 200
          Rails.logger.error("Sophos pull tenants error. Code #{response.code} with message #{body}")
          return
        end

        items = body["items"]
        if page < body["pages"]["total"]
          items + make_api_call(page + 1)
        else
          items
        end
      rescue Errno::ECONNRESET
        raise Sophos::ConnectionPeerResetError
      end

      def persist(data)
        Sophos::SaveTemplates::Tenants.new(@credential, data).call
      end

      def schedule_next
        wait = @options.fetch(:wait, DEFAULT_WAIT)
        ServiceRunnerJob
          .set(wait: wait, queue: :utility)
          .perform_later("Sophos::Services::PullTenants", @credential)
      end

      def url
        @url ||= if partner_id
                   URL_LOOKUP[:partner]
                 elsif organization_id
                   URL_LOOKUP[:organization]
                 end
      end

      def build_headers
        id_header = if partner_id
                      { "X-Partner-ID" => @credential.partner_id }
                    elsif organization_id
                      { "X-Organization-ID" => @credential.organization_id }
                    else
                      {}
                    end
        { Authorization: "Bearer #{@credential.access_token}" }.merge(id_header)
      end

      def build_query(page)
        page_query = page ? { "page" => page } : {}
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
