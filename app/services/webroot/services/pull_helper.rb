# :nodoc
module Webroot
  # :nodoc
  module Services
    # :nodoc
    class PullHelper
      include ErrorHelper
      include PostApiCallProcessor

      URL_BASE = "https://unityapi.webrootcloudav.com".freeze

      def initialize(params = {})
        @params = params
        @cred = Credential.find(@params[:cred_id])
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        return if (@cred&.account&.billing_account&.paid_thru || 1.second.ago) < DateTime.current

        sites = pull_sites if @params[:force_pull_sites]
        sites ||= @cred.sites || pull_sites

        sites.keys.each do |site|
          enqueue_pull(site)
        end
      end

      private

      def make_api_call(url, token, body = {})
        request = HTTPI::Request.new
        request.url = url
        request.headers = { Authorization: "Bearer #{token}" }
        request.body = body
        resp = HTTPI.get(request)
        credential_is_working(resp)
        return if html_error(__FILE__, resp)

        JSON.parse(resp.raw_body)
      end

      def pull_sites
        token = Webroot::Services::CredentialUpdater.new(@cred).call
        url = "#{URL_BASE}/service/api/console/gsm/#{@cred.webroot_gsm_key}/sites"
        data = make_api_call(url, token)

        # this selects the SiteId of all sites which are not deactivated or suspended
        sites = @cred.sites || data["Sites"].pluck("SiteId", "SiteName", "Deactivated", "Suspended")
                                            .map { |one| [one[0], one[1]] unless one[2] || one[3] }
                                            .compact.to_h.reject { |a, _b| a.blank? }
        @cred.update(sites: sites) if sites.present?
        sites
      rescue NoMethodError
        Rails.logger.tagged("PullHelper") do
          Rails.logger.fatal(
            "NoMethodError in PullHelper for credential \# #{@cred.id}"
          )
        end
        []
      end

      def enqueue_pull(site)
        url = "#{URL_BASE}/service/api/console/gsm/#{@cred.webroot_gsm_key}/sites/#{site}/threathistory"
        @params[:url] = url
        ServiceRunnerJob.perform_later("Webroot::Services::Pull", @cred.id, @params)
        @params.delete(:url)
      end
    end
  end
end
