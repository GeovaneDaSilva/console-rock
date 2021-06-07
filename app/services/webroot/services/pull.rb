# :nodoc
module Webroot
  # :nodoc
  module Services
    # :nodoc
    class Pull
      include ErrorHelper
      include PostApiCallProcessor

      def initialize(cred_id, params = {})
        @cred = Credential.find(cred_id)
        @type = "threats"
        @params = params
        @query = params.except(:url, :method, :wait)
        @url = params[:url]
        @method = "get"
        @wait = rand(55..75).minutes
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::Webroot) || @url.nil?
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current

        success = events
        schedule_next(success)
      end

      private

      def make_api_call(token)
        headers = {
          Authorization: "Bearer #{token}"
        }
        request = HTTPI::Request.new
        request.url = @url
        request.headers = headers
        request.query = @query

        if @method == "get"
          HTTPI.get(request)
        elsif @method == "put"
          HTTPI.put(request)
        elsif @method == "post"
          HTTPI.post(request)
        end
      end

      def events
        token = Webroot::Services::CredentialUpdater.new(@cred).call

        resp = make_api_call(token)
        credential_is_working(resp)

        return if html_error(__FILE__, resp)

        process(resp)
      end

      def process(resp)
        temp = JSON.parse(resp.raw_body)
        if temp.dig("MoreAvailable")
          ServiceRunnerJob
            .set(queue: :utility)
            .perform_later(
              "Webroot::Services::Pull", @cred.id, @params.merge({ "PageNr" => temp["PageNr"] + 1 })
            )
        end
        return if temp.dig("ThreatRecords").nil?

        ServiceRunnerJob.set(queue: :utility).perform_later(
          "Webroot::SaveTemplates::#{@type.camelize}",
          nil, @cred.id, temp.dig("ThreatRecords"), @url
        )
        true
      end

      def schedule_next(success)
        return unless PIPELINE_TRIALS.include?(-1) # it does not, so this will always return

        # @params[:start_date] = DateTime.current.utc.iso8601 if success
        @params[:start_date] = 2.weeks.ago.utc.iso8601 if success

        ServiceRunnerJob
          .set(wait: @wait, queue: :utility)
          .perform_later("Webroot::Services::Pull", @cred.id, @params)
      end
    end
  end
end
