# :nodoc
module DeepInstinct
  # :nodoc
  module Services
    # :nodoc
    class PullMsps
      include ErrorHelper

      DEFAULT_URL = "https://partner1.poc.deepinstinctweb.com".freeze

      def initialize(cred, params = {})
        @cred = cred.is_a?(Integer) ? Credentials::DeepInstinct.find(cred) : cred
        webroot_base_url = @cred.base_url || DEFAULT_URL
        url = "#{webroot_base_url}/api/v1/multitenancy/msp/"
        @params = params.merge(url: url)
        @wait = 24.hours
      rescue ActiveRecord::RecordNotFound, NoMethodError
        @cred = nil
      end

      def call
        return if @cred.nil? || !@cred.instance_of?(Credentials::DeepInstinct)
        return if (@cred.account || @cred.customer).billing_account.paid_thru < DateTime.current

        result = msps
        process(result)
        schedule_next

        result
      end

      private

      def process(list)
        return if list.blank?

        @cred.msps = [] if @cred.msps.blank?
        @cred.msps |= list
        @cred.save
      end

      def msps
        # TODO: if number of msps increase will need to use the last_id parameter
        resp = DeepInstinct::Services::Pull.new(@cred, { url: @params[:url] }).call
        resp&.dig("msps")
      end

      def schedule_next
        ServiceRunnerJob
          .set(wait: @wait, queue: :utility)
          .perform_later("DeepInstinct::Services::PullMsps", @cred.id)
      end
    end
  end
end
