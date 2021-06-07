module Integrations
  module Syncro
    # Pull customer data from PSAs
    class TicketActions
      include PostApiCallProcessor

      def initialize(method, credential, incident, psa_config, account = nil, incident_params = nil)
        @method = method
        @credential = credential
        @incident = incident
        @account = account
        @psa_config = psa_config
        @incident_params = incident_params
        @psa_customer_map = @psa_config&.psa_customer_maps&.find_by(account_id: @incident.account.id)
        @base_url = @credential.base_url
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

        JSON.parse(resp.raw_body)
      end

      def headers
        {
          Authorization: "Bearer #{@credential.syncro_api_key}",
        Accept: "application/json",
        "Content-Type" => "application/json"
        }
      end

      def create_ticket
        url = "#{@base_url}/tickets"
        body = {
          "subject"     => "#{@incident.title} - #{@incident.id}",
          "customer_id" => @psa_customer_map.psa_company_id,
          "status"      => @psa_config.new_ticket_code
        }
        body["ticket_type_id"] = @psa_config.board unless @psa_config.board.nil?
        body = body.to_json

        data = make_api_call(url, {}, body, "post")
        new_ticket_id = "#{data.dig('ticket', 'id')}-#{data.dig('ticket', 'number')}"
        raise ::StandardError, "#{@incident.id}--#{url}--#{body}" if new_ticket_id.blank?

        @incident.update(psa_id: new_ticket_id)

        comment_on_ticket(new_ticket_id)
      end

      def comment_on_ticket(psa_id)
        # Some Syncro endpoints use the ticket ID, some use the ticket NUMBER.
        # So we store both in the <psa_id> field, and use whichever is needed
        id = psa_id.split("-").last
        url = "#{@base_url}/tickets/#{id}/comment"
        body = description_builder
        make_api_call(url, {}, body, "post")
      end

      def update_ticket
        return if @psa_config.in_progress_ticket_code.nil? || @incident.psa_id.nil?

        id = @incident.psa_id&.split("-")&.last
        url = "#{@base_url}/tickets/#{id}"
        body = { "status" => @psa_config.in_progress_ticket_code }.to_json

        make_api_call(url, {}, body, "put")
      end

      def close_ticket
        return if @incident.psa_id.nil?

        id = @incident.psa_id&.split("-")&.last
        url = "#{@base_url}/tickets/#{id}"
        body = { "status" => @psa_config.closed_ticket_code }.to_json

        make_api_call(url, {}, body, "put")
      end

      def description_builder
        {
          "subject"      => "Initial Issue",
          "body"         => payload_builder,
          "hidden"       => false,
          "do_not_email" => true
        }.to_json
      end

      def payload_builder
        ApplicationController.renderer.render(
          partial: "/accounts/apps/incidents/summary", locals: { incident: @incident }, formats: :erb
        )
      end
    end
  end
end
