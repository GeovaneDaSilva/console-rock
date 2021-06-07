# :nodoc
module Duo
  # :nodoc
  module Services
    # :nodoc
    class PullAdminLogs
      include ErrorHelper

      PATH = "/admin/v1/logs/administrator".freeze

      def initialize(cred, params = {})
        @cred = cred.is_a?(Integer) ? Credentials::Duo.find(cred) : cred
        @params = params.merge({ "url"     => PATH,
                                 "mintime" => 8.hours.ago.to_i })
        @wait = rand(5..8).hours
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::Duo)
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current

        resp = Duo::Services::Pull.new(@cred.id, @params).call
        (resp&.dig("response") || []).each do |adminlog|
          ServiceRunnerJob.set(queue: :utility).perform_later(
            "Duo::SaveTemplates::AdminLogs", nil, @cred.id, adminlog
          )
        end

        # Note: polling here, watchout
        schedule_next
      end

      private

      def schedule_next
        ServiceRunnerJob
          .set(wait: @wait, queue: :utility)
          .perform_later("Duo::Services::PullAdminLogs", @cred.id)
      end
    end
  end
end
