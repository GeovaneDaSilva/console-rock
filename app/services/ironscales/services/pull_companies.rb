# :nodoc
module Ironscales
  # :nodoc
  module Services
    # :nodoc
    class PullCompanies
      include ErrorHelper

      COMPANY_LIST_URL = "https://members.ironscales.com:443/appapi/company/list/".freeze

      # TODO: This entire file should not be necessary.
      # You should be able to call PULL twice from the controller and accomplish the same thing.
      # For some reason (probably a race condition in the save template) that was overwriting the values of
      # the first call with those of the second.  Using 'with_lock' and 'with_advisory_lock' did not help.
      def initialize(cred, params = {})
        @cred = cred.is_a?(Integer) ? Credentials::Ironscales.find(cred) : cred
        @params = params.merge(url: COMPANY_LIST_URL, name: @cred.company_name,
          domain: @cred.company_domain, save_template: "Ironscales::SaveTemplates::Companies")
        @wait = 24.hours
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::Ironscales)
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current

        result = companies
        process(result)

        # This part should not be necessary, but for some reason if you put this same call
        # in the controller, it overwrites the first call's values (probably a race condition)
        @params = @params.except(:name, :domain)
        result2 = companies
        process(result2)
        schedule_next

        result
      end

      private

      def process(company_list)
        return if company_list.blank?

        @cred.companies = [] if @cred.companies.blank?
        @cred.companies |= company_list
        @cred.save
      end

      def companies
        resp = Ironscales::Services::Pull.new(@cred.id, @params).call
        resp&.dig("companies")
      end

      def schedule_next
        ServiceRunnerJob
          .set(wait: @wait, queue: :utility)
          .perform_later("Ironscales::Services::PullCompanies", @cred.id)
      end
    end
  end
end
