module Integrations
  module Connectwise
    # Pull customer data from PSAs
    class SetupActions
      include ErrorHelper
      include PostApiCallProcessor

      CONNECTWISE_API_REV = "/v4_6_release/apis/3.0".freeze

      def self.get_boards(credential)
        url = "#{base_url(credential)}/service/info/boards"
        query = {
          "conditions" => "projectFlag=false and inactiveFlag=false",
          "fields"     => "id,name",
          "orderBy"    => "name",
          "pagesize"   => 500
        }
        data, = make_api_call(credential, url, query, {}, "get")
        data&.map { |n| [n["name"], n["id"]] }
      end

      def self.get_board_statuses(credential, psa_config)
        # needs them to select a board so I know which board to get the statuses from.
        url = "#{base_url(credential)}/service/boards/#{psa_config.board}/statuses"
        query = {
          "conditions" => "inactive=false"
        }

        data, = make_api_call(credential, url, query, {}, "get")
        data&.map { |n| [n["name"], n["id"]] }
      end

      def self.get_companies(credential, psa_config)
        company_types = psa_config.company_types&.map { |n| "types/name=\"#{n[0]}\"" }
        url = "#{base_url(credential)}/company/companies"
        query = {
          "status/name"     => "Active",
          "fields"          => "id,name,types",
          "orderBy"         => "name",
          "childConditions" => company_types&.join(" or "),
          "pagesize"        => 500
        }

        data = pagination(credential, url, query, {}, "get")
        data&.map do |n|
          types = n.fetch("types", []).map { |type| type.dig("id") }
          [n["name"], n["id"], types]
        end
      end

      def self.get_company_types(credential)
        url = "#{base_url(credential)}/company/companies/types"
        query = { "status/name" => "Active", "fields" => "id,name", "orderBy" => "name", "pagesize" => 100 }

        data, = make_api_call(credential, url, query, {}, "get")
        data&.map { |n| [n["name"], n["id"]] } unless data.nil?
      end

      def self.base_url(credential)
        "#{credential.base_url}#{CONNECTWISE_API_REV}"
      end

      def self.auth_string(credential)
        # Authorization: Basic base64(companyid+publickey:privatekey)
        # rubocop:disable Layout/LineLength
        Base64.encode64("#{credential.connectwise_company_id}+#{credential.connectwise_psa_public_api_key}:#{credential.connectwise_psa_private_api_key}").delete("\n")
        # rubocop:enable Layout/LineLength
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

        [JSON.parse(resp.raw_body), resp.headers["link"]]
      end

      def self.pagination(credential, url, query = {}, body = {}, method = "get")
        counter = 1
        data, next_url = make_api_call(credential, url, query, body, method)
        next_url = make_next_url(next_url)

        while !next_url.nil? && counter < 1000
          new_data, next_url = make_api_call(credential, next_url, {}, body, "get")
          next_url = make_next_url(next_url)
          data += new_data
          counter += 1
        end
        data
      end

      def self.make_next_url(next_url)
        tmp = next_url&.match(/^.*<\s*(?<target_string>[^>]+)\s*>; rel=\"next\",.*$/)
        tmp.nil? ? nil : tmp["target_string"]
      end

      def self.headers(credential)
        {
          clientId:      ENV["CONNECTWISE_API_CLIENT_ID"],
          Authorization: "Basic #{auth_string(credential)}"
        }
      end

      def self.payload_builder(incident)
        ApplicationController.renderer.render(
          partial: "/accounts/apps/incidents/summary", locals: { incident: incident }, formats: :erb
        )
      end
    end
  end
end
