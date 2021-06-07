# :nodoc
module Cysurance
  # :nodoc
  class Protect
    include ErrorHelper

    def initialize(account, app, data)
      @app = app.is_a?(Integer) ? Apps::CysuranceApp.find(app) : app
      @account = account.is_a?(Integer) ? Account.find(account) : account
      @data = data
      @data = preprocess(data)
    rescue ActiveRecord::RecordNotFound, NoMethodError
      @app = nil
      @account = nil
    end

    def call
      return if @account.nil? || @data.size <= 5 || !@account.is_a?(Account) || @app.nil?
      return if @account.billing_account.paid_thru < DateTime.current

      raise "No value for CYSURANCE SALT" if @data["SALT"].nil?

      resp = make_api_call
      return if html_error(__FILE__, resp)

      save(JSON.parse(resp.raw_body))
    end

    private

    def preprocess(data)
      res = {}
      data.each { |k, v| res[k.upcase] = v }

      res["ACCOUNT_ID"]    = "NA"
      res["SALT"]          = ENV["CYSURANCE_SALT"]
      res["PARTNER_CODE"]  = ENV["CYSURANCE_PARTNER_CODE"]
      res["POLICY_TYPE"]   = "RP"
      res["SHOW_PRICE_YN"] = "N"
      res
    end

    def save(response)
      if response.include?("SUCCESS") || response["STATUS_FLAG"] == 200
        current_time = DateTime.current
        cysurance_result = Apps::CysuranceResult.new(
          app_id:         @app.id,
          detection_date: current_time,
          value:          [query.dig("IN_NAME"), query.dig("IN_COMPANY_NAME")].join("-"),
          value_type:     current_time.to_s,
          customer_id:    @account.id,
          details:        app_result_details,
          verdict:        :informational,
          account_path:   @account.path,
          external_id:    hash_contents
        )
        ServiceRunnerJob.perform_later("Apps::Results::Processor", cysurance_result) if cysurance_result.save

        return [response, cysurance_result]
      end
      [response, nil]
    end

    def url
      root = Rails.env.development? || ENV["RAILS_ENV"] == "staging" ? "dev" : "enroll"
      "https://#{root}.cysurance.com/wp-json/enrollment/protect"
    end

    def app_result_details
      details = @data.reject do |k, _v|
        %w[ACCOUNT_ID SALT PARTNER_CODE POLICY_TYPE SHOW_PRICE_YN CANCEL_YN].include? k
      end
      { "type" => "Cysurance", "attributes" => details }
    end

    def query
      @data[:HASH] = hash_contents
      @data
    end

    def hash_contents
      hash = %w[salt country_code partner_code account_id coverage_limit
                in_name in_email in_address1 in_city in_state].collect do |k|
        @data[k.upcase]
      end
      Digest::MD5.hexdigest hash.join
    end

    def make_api_call
      headers = {
        "Accept"       => "application/json",
        "Content-Type" => "application/json"
      }
      request = HTTPI::Request.new
      request.url = url
      request.headers = headers
      request.body = query.to_json
      begin
        HTTPI.post(request)
      rescue Errno::ECONNRESET
        raise Cysurance::ConnectionPeerResetError
      end
    end
  end
end
