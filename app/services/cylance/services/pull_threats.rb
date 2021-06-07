# :nodoc
module Cylance
  # :nodoc
  module Services
    # :nodoc
    class PullThreats
      include ErrorHelper

      URL = "https://protectapi.cylance.com".freeze

      def initialize(cred, params = {})
        @cred = cred.is_a?(Integer) ? Credentials::Cylance.find(cred) : cred
        base_url = @cred.base_url || URL
        url = "#{base_url}/threats/v2"
        @params = params.merge({ "url" => url })
        @wait = rand(35..65).minutes
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::Cylance)
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current

        resp = Cylance::Services::Pull.new(@cred.id, @params).call
        (resp&.dig("page_items") || []).each do |threat|
          ServiceRunnerJob.set(queue: :utility).perform_later(
            "Cylance::SaveTemplates::Threats",
            nil, @cred.id, threat
          )
        end

        success = continue_processing(resp)

        # Note: polling here, watchout
        schedule_next if success
      end

      private

      def continue_processing(resp)
        if (resp&.dig("page_number") || 0) < (resp&.dig("total_pages") || 0)
          ServiceRunnerJob
            .set(queue: :utility)
            .perform_later(
              "Cylance::Services::PullThreats",
              @cred.id,
              @params.merge({ "page" => resp.dig("page_number") + 1 })
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
          .perform_later("Cylance::Services::PullThreats", @cred.id)
      end
    end
  end
end
