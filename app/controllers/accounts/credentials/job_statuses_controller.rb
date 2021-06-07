module Accounts
  module Credentials
    # Account scoped credentials test
    class JobStatusesController < AuthenticatedController
      def show
        authorize current_account, :can_manage_apps?

        status = job_status
        render json: { status: status, message: message(status) }
      rescue NoJobError
        render json: { status: "completed" }
      end

      private

      def job_status
        job_id = params.dig("job_id")
        status = ActiveJob::Status.get(job_id)

        begin
          status[:status].blank? ? (raise NoJobError) : status[:status]
        rescue NoMethodError
          raise NoJobError
        end
      end

      def message(status)
        case status.to_s.downcase
        when "queued"
          "Preparing to pull your information."
        when "completed"
          "Processing information done."
        when "working"
          "We're pulling your information now. This may take a few minutes..."
        when "failed"
          "Pulling information failed."
        else
          "No command to pull information found."
        end
      end
    end

    # nodoc
    class NoJobError < StandardError
      def initialize(msg = "No command to pull information found.")
        super
      end
    end
  end
end
