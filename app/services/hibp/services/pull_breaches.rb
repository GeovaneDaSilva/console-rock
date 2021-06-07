# :nodoc
module Hibp
  # :nodoc
  module Services
    # :nodoc
    class PullBreaches
      def initialize(credential, first_pull = false, should_schedule_next = true)
        @credential = credential.is_a?(Integer) ? Credentials::Hibp.find(credential) : credential
        @first_pull = first_pull
        @should_schedule_next = should_schedule_next
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @credential = nil
      end

      # rubocop:disable Metrics/MethodLength
      def call
        return if @credential.nil? || !@credential.instance_of?(Credentials::Hibp)
        return if @credential.account.billing_account.paid_thru < DateTime.current

        i = 0
        @credential.account.all_descendant_customers.each do |acc|
          (emails(acc) || []).each do |email|
            ServiceRunnerJob.set(wait: (2 * i).seconds).perform_later(
              "Hibp::Services::Pull", @credential,
              "breachedaccount", acc.id, email,
              { truncateResponse: false }, @first_pull
            )
            i += 1
          end

          i = 0
          (domains(acc) || []).each do |domain|
            ServiceRunnerJob.set(wait: (2 * i).seconds).perform_later(
              "Hibp::Services::Pull", @credential, "breaches", acc.id, nil,
              { truncateResponse: false, domain: domain }
            )
            i += 1
          end
        end

        schedule_next if @should_schedule_next
      end
      # rubocop:enable Metrics/MethodLength

      private

      def emails(account)
        result = @credential.keys.dig("emails", account.id.to_s) || []
        result |= [account.subscriptions.map(&:email_address),
                   Email.where(account_id: account.id).collect(&:emails).flatten,
                   account.users.map(&:email)].flatten.compact.uniq
        # TODO: THIS PART WILL NEED TO CHANGE WHEN WE START USING ID RATHER THAN EMAIL AS EXTERNAL_ID
        result |= account.all_descendant_billable_instances.office_365_mailbox.pluck(:external_id)
        result.uniq
      end

      def domains(account)
        @credential.keys.dig("domains", account.id.to_s)
      end

      def schedule_next
        return unless PIPELINE_TRIALS.include?(-1) # i.e. "false"

        ServiceRunnerJob
          .set(wait: 4.hours, queue: :utility)
          .perform_later("Hibp::Services::PullBreaches", @credential.id)
      end
    end
  end
end
