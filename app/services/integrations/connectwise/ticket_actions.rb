module Integrations
  # :nodoc:
  module Connectwise
    # Pull customer data from PSAs
    class TicketActions
      include ErrorHelper
      include PostApiCallProcessor

      CONNECTWISE_API_REV = "/v4_6_release/apis/3.0".freeze

      def initialize(method, credential, incident, psa_config, account = nil, incident_params = nil)
        @method = method
        @credential = credential
        @incident = incident
        @account = account
        @psa_config = psa_config
        @incident_params = incident_params
        @base_url = "#{@credential.base_url}#{CONNECTWISE_API_REV}"
        @psa_customer_map = @psa_config.psa_customer_maps.find_by(account_id: @incident.account.id)
      rescue NoMethodError, ActiveRecord::RecordNotFound
        @psa_customer_map = nil
      end

      def call
        return if !@psa_customer_map.is_a?(PsaCustomerMap) || !@incident.is_a?(Apps::Incident)
        return unless @psa_config.is_a?(PsaConfig) && @credential.is_a?(Credential)

        send(@method)
      end

      private

      def create_ticket
        url = "#{@base_url}/service/tickets"
        body = {
          "summary"            => "#{@incident.title} - #{@incident.id}".truncate(99),
          "initialDescription" => payload_builder,
          "board"              => { "id" => @psa_config.board },
          "status"             => { "id" => @psa_config.new_ticket_code },
          "company"            => { "id" => @psa_customer_map.psa_company_id }
        }.to_json

        data = make_api_call(url, {}, body, "post")
        raise ::StandardError, "#{@incident.id}--#{url}--#{body}" if data.nil?

        @incident.update(psa_id: data["id"])
      end

      def update_ticket
        return if @psa_config.in_progress_ticket_code.nil? || @incident.psa_id.nil?

        url = "#{@base_url}/service/tickets/#{@incident.psa_id}"
        body = [
          {
            "op"    => "replace",
            "path"  => "status/id",
            "value" => @psa_config.in_progress_ticket_code
          }
        ]
        # the above pattern works for updating anything.  A field, a company, etc.
        patch_request(url, body)
        # TODO: find some way to link a device?
      end

      def close_ticket
        return if @psa_config.closed_ticket_code.nil? || @incident.psa_id.nil?

        url = "#{@base_url}/service/tickets/#{@incident.psa_id}"
        body = [
          {
            "op":    "replace",
            "path":  "status/id",
            "value": @psa_config.closed_ticket_code
          }
        ]

        patch_request(url, body)
      end

      def delete_ticket
        # !!!! This should not normally be used.
        url = "#{@base_url}/service/tickets/#{@incident.psa_id}"
        patch_request(url, {}, body, "delete")
      end

      def base_url
        "#{@credential.base_url}#{CONNECTWISE_API_REV}"
      end

      def auth_string
        # Authorization: Basic base64(companyid+publickey:privatekey)
        # rubocop:disable Layout/LineLength
        @auth_string ||= Base64.encode64("#{@credential.connectwise_company_id}+#{@credential.connectwise_psa_public_api_key}:#{@credential.connectwise_psa_private_api_key}").delete("\n")
        # rubocop:enable Layout/LineLength
      end

      def make_api_call(url, query = {}, body = {}, method = "get")
        request = HTTPI::Request.new
        request.url = url
        request.headers = headers
        request.query = query if query.present?
        request.body = body if body.present?

        resp = nil
        if method == "get"
          resp = HTTPI.get(request)
        elsif method == "put"
          resp = HTTPI.put(request)
        elsif method == "delete"
          resp = HTTPI.delete(request)
        elsif method == "post"
          resp = HTTPI.post(request)
        end

        credential_is_working(resp)
        return if resp.code > 299

        JSON.parse(resp.raw_body)
      end

      def headers
        {
          clientId: ENV["CONNECTWISE_API_CLIENT_ID"],
          Authorization: "Basic #{auth_string}",
          "Content-Type" => "application/json"
        }
      end

      def payload_builder
        ApplicationController.renderer.render(
          partial: "/accounts/apps/incidents/summary", locals: { incident: @incident }, formats: :erb
        )
      end

      def patch_request(url, body)
        uri = URI.parse(url)
        request = Net::HTTP::Patch.new(uri)
        request.content_type = "application/json"
        request["Clientid"] = ENV["CONNECTWISE_API_CLIENT_ID"]
        request["Authorization"] = headers[:Authorization].delete("\n")
        request.body = JSON.dump(body)

        req_options = {
          use_ssl: uri.scheme == "https"
        }

        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end
        return if response.code.to_i > 299

        JSON.parse(response.body)
      end
    end
  end
end
