# :nodoc
module Ironscales
  # :nodoc
  module Services
    # :nodoc
    class Pull
      include ErrorHelper
      include PostApiCallProcessor

      def initialize(cred, params = {})
        @cred = cred.is_a?(Integer) ? Credentials::Ironscales.find(cred) : cred
        @params = params
        @query = params.except(:url, :wait, :call_details, :save_template, :not_recurring, :company_id)
        @wait = params[:wait] || rand(45..75).minutes
        @url = params[:url] || params["url"]
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::Ironscales) || @url.nil?

        results = events

        if @params[:call_details]
          call_details(results)
        elsif !@params[:save_template].nil?
          ServiceRunnerJob.perform_later(@params[:save_template], @cred.id, results, @params[:company_id])
        end
        results
      end

      private

      def make_api_call(access_token)
        request = HTTPI::Request.new
        request.url = @url
        request.headers = { Authorization: "Bearer #{access_token}" }
        request.query = @query

        HTTPI.get(request)
      end

      def events
        access_token = Ironscales::Services::CredentialUpdater.new(@cred).call

        resp = make_api_call(access_token)
        credential_is_working(resp)

        return if html_error(__FILE__, resp)

        schedule_next unless @params[:not_recurring]
        JSON.parse(resp.raw_body)
      end

      def call_details(results)
        details_params = { not_recurring: true, save_template: "Ironscales::SaveTemplates::Incident" }
        params = @params.dup.except(:call_details).merge(details_params)

        (results&.dig("incidents") || []).each do |result|
          # rubocop:disable Layout/LineLength
          params[:url] = "https://members.ironscales.com:443/appapi/incident/#{params[:company_id]}/details/#{result['incidentID']}"
          # rubocop:enable Layout/LineLength
          ServiceRunnerJob.perform_later("Ironscales::Services::Pull", @cred.id, params)
        end
      end

      def schedule_next
        return if @params[:url].include?("mitigation") # disable all incident and Impersonation jobs

        ServiceRunnerJob.set(wait: @wait).perform_later(
          "Ironscales::Services::Pull", @cred.id, @params
        )
      end
    end
  end
end
