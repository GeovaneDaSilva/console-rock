module Integrations
  module Syncro
    # Pull customer data from PSAs
    class SetupActions
      include PostApiCallProcessor

      def self.pull_setup_data(credential)
        url = "#{credential.base_url}/tickets/settings"
        ticket_data = make_api_call(credential, url, {}, {}, "get")
        company_data = pull_companies(credential)

        {
          companies:     company_data.sort_by { |n| n[0].downcase },
          board_options: ticket_data.dig("ticket_types")&.map { |n| [n["name"], n["id"]] },
          status_codes:  ticket_data.dig("ticket_status_list")
        }
      end

      def self.pull_companies(credential)
        url = "#{credential.base_url}/customers"

        data = pagination(credential, url, {}, {}, "get")
        # Rails.logger.info("Syncro - PullCompanies - #{@credential.id} - #{data&.first}")
        # NOTE: we pass an empty array at the end to indicate that there is no type for the company
        data&.map { |n| [n["business_name"].presence || n["fullname"], n["id"], []] }
      end

      def self.headers(credential)
        { Authorization: "Bearer #{credential.syncro_api_key}" }
      end

      def self.make_api_call(credential, url, query = {}, body = {}, method = "get")
        request = HTTPI::Request.new
        request.url = url
        request.headers = headers(credential)
        request.query = query if query.present?
        request.body = body if body.present?

        resp = nil
        if method == "get"
          resp = HTTPI.get(request)
        elsif method == "put"
          resp = HTTPI.put(request)
        elsif method == "post"
          resp = HTTPI.post(request)
        end

        credential_is_working(credential, resp)
        return if resp.code > 299

        JSON.parse(resp.raw_body)
      end

      def self.pagination(credential, url, query = {}, body = {}, method = "get", _target = nil)
        counter = 1
        data = make_api_call(credential, url, query, body, method)
        keep_going = (data&.dig("meta", "page") || 1) < (data&.dig("meta", "total_pages") || 1)
        next_page = (data&.dig("meta", "page") || 0) + 1
        # TODO: These explicit calls to customers limits the abstractability of this call.  Fix.
        data = data["customers"]

        while keep_going && counter < 100
          new_data = make_api_call(credential, url, { page: next_page }, body, "get")
          keep_going = (new_data&.dig("meta", "page") || 1) < (new_data&.dig("meta", "total_pages") || 1)
          next_page = (new_data&.dig("meta", "page") || 0) + 1
          data += new_data["customers"]
          counter += 1
        end
        data
      end
    end
  end
end
