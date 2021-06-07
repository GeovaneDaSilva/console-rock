module Integrations
  module Datto
    # Pull customer data from PSAs
    class SetupActions
      include PostApiCallProcessor

      DATTO_API_REV = "v1.0".freeze

      def self.get_boards(credential)
        # DATTO gets both boards and statuses at the same time, since statuses cannot vary by board
        # (or so it seems).  First, lookup what base_url I should use for this creential.
        result = do_zone_request(credential)
        return if result.nil?

        # Now, get the boards and status_codes
        save_data = pull_boards_and_status_codes(credential)

        # Now, get the company types
        pull_company_types(credential, save_data)
      end

      def self.get_companies(credential, psa_config)
        url = "#{base_url(credential)}/Companies/query"
        company_type_list = []
        psa_config.company_types.each do |type|
          company_type_list << { "op": "eq", "field": "CompanyType", "value": type[1].to_s }
        end
        query = {
          "search" => {
            "filter":        [
              { "op": "eq", "field": "IsActive", "value": true },
              { "op": "or", "items": company_type_list }
            ],
            "IncludeFields": %w[id companyName companyType]
          }.to_json
        }

        data = pagination(credential, url, query, {}, "get")
        data&.map { |n| [n["companyName"], n["id"], [n["companyType"]]] }
      end

      def self.base_url(credential)
        "#{credential.base_url}#{DATTO_API_REV}"
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

      def self.pagination(credential, url, query = {}, body = {}, method = "get")
        counter = 1
        data = make_api_call(credential, url, query, body, method)
        next_url = data.dig("pageDetails", "nextPageUrl")
        company_data = data.dig("items") || []

        while !next_url.nil? && counter < 10
          new_data = make_api_call(credential, next_url, {}, body, "get")
          next_url = new_data.dig("pageDetails", "nextPageUrl")
          # data += new_data
          company_data += new_data.dig("items") || []
          counter += 1
        end
        company_data
      end

      def self.headers(credential)
        {
          ApiIntegrationCode: ENV["DATTO_INTEGRATION_CODE"],
          UserName: credential.datto_psa_username,
          Secret: credential.datto_psa_secret,
          Accept: "application/json",
          "Content-Type" => "application/json"
        }
      end

      def self.do_zone_request(credential)
        zone_request = HTTPI::Request.new
        zone_request.url = "https://webservices.autotask.net/atservicesrest/v1.0/zoneInformation"
        zone_request.query = { "user" => credential.datto_psa_username }
        resp = HTTPI.get(zone_request)
        return if resp.code > 299

        zone_data = JSON.parse(resp.raw_body)
        credential.update(base_url: zone_data["url"])
      end

      def self.pull_boards_and_status_codes(credential)
        url = "#{base_url(credential)}/Tickets/entityInformation/fields"
        # I would prefer to only pick out the two I want, but Datto's API can't handle that
        wanted = %w[queueid status priority]
        query = { "IncludeFields": %w[name picklistValues sortOrder] }
        data = make_api_call(credential, url, query, {}, "get")&.dig("fields")
                                                   &.map do |n|
                 [n["name"].downcase, n["picklistValues"]] if wanted.include?(n["name"].downcase)
               end&.compact&.to_h

        priority = select_priority(data["priority"])

        new_data = {}
        (data || []).each do |key, value|
          filtered_values = []
          value.each do |hsh|
            filtered_values << [hsh["label"], hsh["value"], hsh["sortOrder"]]
          end
          # sort by sortOrder
          filtered_values.sort_by(&:last)
          # remove sortOrder from the values being saved
          new_data[key] = filtered_values.map { |n| n[0..-2] }
        end

        { board_options: new_data["queueid"], status_codes: new_data["status"], datto_priority: priority }
      end

      def self.pull_company_types(credential, save_data)
        url = "#{base_url(credential)}/Companies/entityInformation/fields"
        # I would prefer to only pick out the two I want, but Datto's API can't handle that
        wanted = ["companytype"]
        query = { "IncludeFields": %w[name picklistValues] }
        data = make_api_call(credential, url, query, {}, "get")&.dig("fields")
                                                   &.map do |n|
                 [n["name"].downcase, n["picklistValues"]] if wanted.include?(n["name"].downcase)
               end&.compact&.to_h

        new_data = {}
        (data || []).each do |key, value|
          filtered_values = []
          value.each do |hsh|
            next unless hsh["isActive"]

            filtered_values << [hsh["label"], hsh["value"]]
          end

          new_data[key] = filtered_values
        end

        save_data[:company_types] = new_data["companytype"]
        save_data
      end

      def self.select_priority(data)
        return nil if data.nil?

        data = data.select { |n| n unless n["isSystem"] || !n["isActive"] }
        words = %w[medium standard default normal]
        priority = data.select { |n| n if words.any? { |word| n["label"].downcase.include?(word) } }
        return priority.min_by { |n| n["sortOrder"] }["value"] if priority.present?

        priority = data.select { |n| n if n["label"].downcase.include?("high") }
                       &.min_by { |n| n["sortOrder"] }
        return priority["value"] if priority.present?

        # If they have completely unique things, just pick the first one.
        data.min_by { |n| n["sortOrder"] }["value"]
      end
    end
  end
end
