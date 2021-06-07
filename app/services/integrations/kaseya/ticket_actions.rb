module Integrations
  module Kaseya
    # CRUD operations on Kaseya tickets
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
        @base_url = "#{@credential.base_url}/api"
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
        return @headers unless @headers.nil?

        token = Credentials::Update::Kaseya.new(@credential).call
        @headers =
          { Authorization: "Bearer #{token}" }
      end

      def create_ticket
        url = "#{@base_url}/servicedesk/tickets"
        body = create_body

        data = make_api_call(url, {}, body, "post")
        new_ticket_id = data&.dig("Id")
        raise ::StandardError, "#{@incident.id}--#{url}--#{body}" if new_ticket_id.blank?

        @incident.update(psa_id: new_ticket_id)
      end

      def update_ticket
        return if @psa_config.in_progress_ticket_code.nil? || @incident.psa_id.nil?

        url = "#{@base_url}/servicedesk/tickets/#{@incident.psa_id}"
        body = pull_ticket.merge(update_params(@psa_config.in_progress_ticket_code))
        data = make_api_call(url, {}, body, "put")
        raise ::StandardError, "update ticket -- #{@incident.id}" if data.nil?
      end

      def close_ticket
        return if @psa_config.closed_ticket_code.nil? || @incident.psa_id.nil?

        url = "#{@base_url}/servicedesk/tickets/#{@incident.psa_id}"
        body = pull_ticket.merge(update_params(@psa_config.closed_ticket_code))
        data = make_api_call(url, {}, body, "put")
        raise ::StandardError, "close ticket -- #{@incident.id}" if data.nil?
      end

      def pull_ticket
        url = "#{@base_url}/servicedesk/tickets/#{@incident.psa_id}"
        data = make_api_call(url, {}, {}, "get")
        data["Result"]&.slice(
          "AccountId", "AccountLocationId", "ContactId", "TicketSourceId", "TicketTypeId", "Title",
          "Details", "PriorityId", "StatusId", "QueueId", "PrimaryAssigneeId", "OpenDate"
        )
      end

      def create_body
        {
          "AccountId":         @psa_customer_map.psa_company_id,
          "AccountLocationId": @psa_config.kaseya_location_map&.dig(@psa_customer_map.psa_company_id),
          "ContactId":         nil,
          "TicketSourceId":    @psa_config.ticket_source,
          "TicketTypeId":      @psa_config.ticket_type,
          "Title":             "#{@incident.title} - #{@incident.id}",
          "Details":           payload_builder,
          "PriorityId":        @psa_config.priority,
          "StatusId":          @psa_config.new_ticket_code,
          "QueueId":           @psa_config.board,
          "PrimaryAssigneeId": nil,
          "OpenDate":          @incident.created_at.iso8601
        }
      end

      def update_params(status_code)
        {
          "Details"  => payload_builder,
          "StatusId" => status_code
        }
      end

      def payload_builder
        ApplicationController.renderer.render(
          partial: "/accounts/apps/incidents/summary", locals: { incident: @incident }, formats: :erb
        )
      end
    end
  end
end
