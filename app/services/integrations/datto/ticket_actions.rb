module Integrations
  module Datto
    # Pull customer data from PSAs
    class TicketActions
      include PostApiCallProcessor

      DATTO_API_REV = "v1.0".freeze

      def initialize(method, credential, incident, psa_config, account = nil, incident_params = nil)
        @method = method
        @credential = credential
        @incident = incident
        @account = account
        @psa_config = psa_config
        @incident_params = incident_params
        @psa_customer_map = @psa_config&.psa_customer_maps&.find_by(account_id: @incident.account.id)
        @base_url = "#{@credential.base_url}#{DATTO_API_REV}"
      rescue NoMethodError, ActiveRecord::RecordNotFound
        @psa_customer_map = nil
      end

      def call
        return if !@psa_customer_map.is_a?(PsaCustomerMap) || !@incident.is_a?(Apps::Incident)
        return unless @psa_config.is_a?(PsaConfig) && @credential.is_a?(Credential)

        send(@method)
      end

      private

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
        elsif method == "post"
          resp = HTTPI.post(request)
        end

        credential_is_working(resp)
        return if resp.code > 299

        # TODO: need to do something about > 299 to make more precise

        JSON.parse(resp.raw_body)
      end

      def headers
        {
          ApiIntegrationCode: ENV["DATTO_INTEGRATION_CODE"],
          UserName: @credential.datto_psa_username,
          Secret: @credential.datto_psa_secret,
          Accept: "application/json",
          "Content-Type" => "application/json"
        }
      end

      # 2 was the default "Medium" priority on our demo account
      # rubocop:disable Metrics/MethodLength
      def create_ticket
        url = "#{@base_url}/Tickets"
        body = {
          "Title"       => "#{@incident.title} - #{@incident.id}",
          "CompanyId"   => @psa_customer_map.psa_company_id,
          "description" => payload_builder,
          "Status"      => @psa_config.new_ticket_code,
          "Priority"    => @psa_config.datto_priority || 2,
          "QueueID"     => @psa_config.board
        }.to_json

        data = make_api_call(url, {}, body, "post")
        # this idiotic nonsense needed because as of this writing, Datto's API endpoints are not consistent
        # in the capitalization of their field names between zones
        if data.nil?
          body = {
            "title"       => "#{@incident.title} - #{@incident.id}",
            "companyId"   => @psa_customer_map.psa_company_id,
            "description" => payload_builder,
            "status"      => @psa_config.new_ticket_code,
            "priority"    => @psa_config.datto_priority || 2,
            "queueID"     => @psa_config.board
          }.to_json
          data = make_api_call(url, {}, body, "post")
          raise ::StandardError, "#{@incident.id}--#{url}--#{body}" if data.nil?
        end

        @incident.update(psa_id: data["itemId"])
      end
      # rubocop:enable Metrics/MethodLength

      def update_ticket
        return if @psa_config.in_progress_ticket_code.nil? || @incident.psa_id.nil?

        url = "#{@base_url}/Tickets"
        body = {
          "id"     => @incident.psa_id,
          "Status" => @psa_config.in_progress_ticket_code
        }

        success = patch_request(url, body)
        return success unless success.nil?

        # see comment on double try in create_ticket
        body = {
          "id"     => @incident.psa_id,
          "status" => @psa_config.in_progress_ticket_code
        }
        patch_request(url, body)
      end

      def close_ticket
        return if @incident.psa_id.nil?

        url = "#{@base_url}/Tickets"
        body = {
          "id"     => @incident.psa_id,
          "Status" => @psa_config.closed_ticket_code
        }

        # just as update, but set to a status that means "Complete"
        success = patch_request(url, body)
        return success unless success.nil?

        # see comment on double try in create_ticket
        body = {
          "id"     => @incident.psa_id,
          "status" => @psa_config.closed_ticket_code
        }
        patch_request(url, body)
      end

      def patch_request(url, body)
        uri = URI.parse(url)
        request = Net::HTTP::Patch.new(uri)
        request.content_type = "application/json"
        request["Apiintegrationcode"] = ENV["DATTO_INTEGRATION_CODE"]
        request["Username"] = @credential.datto_psa_username
        request["Secret"] = @credential.datto_psa_secret
        request["Accept"] = "application/json"
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

      def payload_builder
        ApplicationController.renderer.render(
          partial: "/accounts/apps/incidents/summary", locals: { incident: @incident }, formats: :erb
        )
      end
    end
  end
end
