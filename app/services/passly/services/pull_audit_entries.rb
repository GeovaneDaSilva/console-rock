# :nodoc
module Passly
  # :nodoc
  module Services
    # :nodoc
    class PullAuditEntries
      include ErrorHelper

      def initialize(cred, params = {})
        @cred = cred.is_a?(Integer) ? Credentials::Passly.find(cred) : cred
        @params = params.merge({ "url" => url })
        @wait = rand(41..77).minutes
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::Passly)
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current
        return if PIPELINE_TRIALS.include?(@cred.account.id)

        resp = Passly::Services::Pull.new(@cred.id, @params).call
        ServiceRunnerJob.set(queue: :utility).perform_later(
          "Passly::SaveTemplates::AuditEntries", nil, @cred.id, resp&.dig("Value")
        )

        schedule_next
      end

      private

      def url
        "https://#{@cred.tenant_id}.my.passly.com/api/directory/Auditing/Query"
      end

      def schedule_next
        return unless PIPELINE_TRIALS.include?(-1)

        ServiceRunnerJob
          .set(wait: @wait, queue: :utility)
          .perform_later("Passly::Services::PullAuditEntries", @cred.id)
      end
    end
  end
end
