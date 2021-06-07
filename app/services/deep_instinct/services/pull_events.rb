# :nodoc
module DeepInstinct
  # :nodoc
  module Services
    # :nodoc
    class PullEvents
      include ErrorHelper

      BASE_ENDPOINT = "/api/v1/events/".freeze
      SEARCH_ENDPOINT = "/api/v1/events/search/".freeze
      BASE_URL = "https://partner1.poc.deepinstinctweb.com".freeze

      def initialize(cred, params = {})
        @cred = cred.is_a?(Integer) ? Credentials::DeepInstinct.find(cred) : cred
        @params = params
        @params.merge!({ url: url })
        @wait = rand(50..70).minutes
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::DeepInstinct)
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current
        return if PIPELINE_TRIALS.include?(@cred.account.id)

        resp = DeepInstinct::Services::Pull.new(@cred, @params).call
        ServiceRunnerJob.set(queue: :utility).perform_later(
          "DeepInstinct::SaveTemplates::Events",
          nil, @cred, resp&.dig("events") || []
        )
        success = continue_processing(resp)

        # Note: polling here, watchout
        schedule_next if success && !@params["once_only"]
      end

      private

      def url
        base_url = @cred.base_url || BASE_URL
        last_id = @params["last_id"] || Apps::DeepInstinctResult.where(credential_id: @cred.id)
                                                                .maximum("external_id")
        if last_id.present?
          @params[:method] = "post"
          "#{base_url}#{SEARCH_ENDPOINT}#{last_id}"
        else
          "#{base_url}#{BASE_ENDPOINT}"
        end
      end

      def continue_processing(resp)
        if resp&.dig("last_id").present?
          ServiceRunnerJob
            .set(queue: :utility)
            .perform_later(
              "DeepInstinct::Services::PullEvents",
              @cred.id,
              @params.merge({ "last_id" => resp.dig("last_id"), "once_only" => true })
            )
          false
        else
          true
        end
      end

      def schedule_next
        return unless PIPELINE_TRIALS.include?(-1)

        ServiceRunnerJob
          .set(wait: @wait, queue: :utility)
          .perform_later("DeepInstinct::Services::PullEvents", @cred.id)
      end
    end
  end
end
