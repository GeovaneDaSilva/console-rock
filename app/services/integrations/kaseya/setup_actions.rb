module Integrations
  module Kaseya
    # Pull customer data from PSAs
    class SetupActions
      include PostApiCallProcessor

      def self.pull_setup_data(credential)
        status_codes = pull_statuses(credential)
        priority_codes = pull_priorities(credential)
        board_options = pull_boards(credential)
        company_types = pull_company_types(credential)
        ticket_types = pull_ticket_types(credential)

        {
          board_options:  board_options,
          status_codes:   status_codes,
          priority_codes: priority_codes,
          company_types:  company_types,
          ticket_types:   ticket_types
        }
      end

      def self.pull_companies(credential, psa_config)
        return unless credential.is_a?(Credentials::Kaseya) && psa_config.is_a?(PsaConfig)

        url = "#{base_url(credential)}/crm/accounts"
        companies = []

        (psa_config.company_types || []).each do |_type_name, type_id|
          query = {
            "$filter"  => "IsActive eq true and AccountTypeId eq #{type_id}",
            "$orderby" => "AccountName"
          }

          results = make_paginated_api_call(credential, url, query, {}, "get")
          companies += results.map do |n|
            locations = n["Locations"].map do |loc|
              loc["Id"] if loc["IsActive"] && loc["IsMain"]
            end .compact.first
            [n["AccountName"], n["Id"], locations, type_id]
          end
        end
        companies1 = companies.map { |name, id, _loc, type_id| [name, id, [type_id]] }
        companies2 = companies.map { |_name, id, loc, _type_id| [id, loc] }.to_h
        # companies
        [companies1, companies2]
      end

      def self.pull_statuses(credential)
        url = "#{base_url(credential)}/system/statuses"
        query = { "$filter" => "IsActive eq true", "$orderby" => "StatusOrder" }
        data = make_api_call(credential, url, query, {}, "get")
        data["Result"]&.map { |n| [n["Name"], n["Id"]] }
      end

      def self.pull_priorities(credential)
        url = "#{base_url(credential)}/system/priorities"
        query = { "$orderby" => "Name" }
        data = make_api_call(credential, url, query, {}, "get")
        data["Result"]&.map { |n| [n["Name"], n["Id"]] }
      end

      def self.pull_boards(credential)
        url = "#{base_url(credential)}/system/queues"
        query = { "$filter" => "IsActive eq true", "$orderby" => "Name" }
        data = make_api_call(credential, url, query, {}, "get")
        data["Result"]&.map { |n| [n["Name"], n["Id"]] }
      end

      def self.pull_company_types(credential)
        url = "#{base_url(credential)}/crm/accounts/types"
        query = { "$filter" => "IsActive eq true", "$orderby" => "Name" }
        data = make_api_call(credential, url, query, {}, "get")
        data["Result"]&.map { |n| [n["Name"], n["Id"]] }
      end

      def self.pull_ticket_types(credential)
        url = "#{base_url(credential)}/system/lists/1"
        query = { "$filter" => "IsActive eq true", "$orderby" => "Id" }
        data = make_api_call(credential, url, query, {}, "get")
        data["Result"]&.map { |n| [n["Name"], n["Id"]] }
      end

      def self.base_url(credential)
        "#{credential.base_url}/api"
      end

      def self.headers(credential)
        token = Credentials::Update::Kaseya.new(credential).call
        { Authorization: "Bearer #{token}" }
      end

      def self.make_paginated_api_call(credential, url, query = {}, body = {}, method = "get")
        requested_size = 100

        records = []
        records_returned_in_last_iteration = 100

        # if the dataset is less than the size limit, then there are no additional records to fetch
        while records_returned_in_last_iteration >= requested_size
          paging = {
            "$top"  => requested_size,
            "$skip" => records.size
          }
          paginated_query = query.merge(paging)
          data = make_api_call(credential, url, paginated_query, body, method)
          results = data["Result"]
          records += results
          records_returned_in_last_iteration = results.size
        end
        records
      end

      # :nodoc
      class RequestError < StandardError
        attr_reader :response
        def initialize(msg = "Request failed!", response = nil)
          super(msg)
          @response = response
        end
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
        # TODO: handle credential failure, empty result sets, etc. errors here
        raise RequestError.new("Request failed with status: #{resp.code}", response) if resp.code > 299

        response = JSON.parse(resp.raw_body)

        response
      end
    end
  end
end
