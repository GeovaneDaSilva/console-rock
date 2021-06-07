# :nodoc
module Passly
  # :nodoc
  module Services
    # :nodoc
    class PullOrganizations
      include ErrorHelper

      def initialize(cred, params = {})
        @cred = cred.is_a?(Integer) ? Credentials::Passly.find(cred) : cred
        @params = params.merge({ "url" => url })
        @wait = rand(5..8).hours
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::Passly)
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current

        resp = Passly::Services::Pull.new(@cred.id, @params).call
        process(resp&.dig("OrganizationLicenses"))

        schedule_next
      end

      private

      def process(organizations)
        return if organizations.blank?

        @cred.organizations = [] if @cred.organizations.blank?
        @cred.organizations |= organizations
        @cred.save
      end

      def url
        "https://#{@cred.tenant_id}.my.passly.com/api/directory/Organizations/TenantLicense"
      end

      def schedule_next
        ServiceRunnerJob
          .set(wait: @wait, queue: :utility)
          .perform_later("Passly::Services::PullOrganizations", @cred.id)
      end
    end
  end
end
