# :nodoc
module Duo
  # :nodoc
  module Services
    # :nodoc
    class PullAuthLogs
      include ErrorHelper

      PATH = "/admin/v2/logs/authentication".freeze

      def initialize(cred, params = {})
        @cred = cred.is_a?(Integer) ? Credentials::Duo.find(cred) : cred
        @params = params.merge({ "url"     => PATH,
                                 "mintime" => 8.hours.ago.strftime("%s%L"),
                                 "maxtime" => Time.current.strftime("%s%L") })
        @wait = rand(5..8).hours
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::Duo)
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current

        resp = Duo::Services::Pull.new(@cred.id, @params).call
        (resp&.dig("response", "authlogs") || []).each do |authlog|
          ServiceRunnerJob.set(queue: :utility).perform_later(
            "Duo::SaveTemplates::AuthLogs", nil, @cred.id, authlog
          )
        end

        success = continue_processing(resp)

        # Note: polling here, watchout
        schedule_next if success
      end

      private

      def continue_processing(resp)
        offset = resp&.dig("response", "metadata", "next_offset")
        if offset
          ServiceRunnerJob
            .set(queue: :utility)
            .perform_later(
              "Duo::Services::PullAuthLogs",
              @cred.id,
              @params.merge({ "offset" => offset })
            )
          false
        else
          true
        end
      end

      def schedule_next
        ServiceRunnerJob
          .set(wait: @wait, queue: :utility)
          .perform_later("Duo::Services::PullAuthLogs", @cred.id)
      end
    end
  end
end
