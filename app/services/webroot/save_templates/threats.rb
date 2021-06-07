# :nodoc
module Webroot
  # :nodoc
  module SaveTemplates
    # :nodoc
    class Threats
      include AntivirusHelper
      def initialize(app_id, cred_id, events, source_guid = nil)
        if events.blank?
          @events = []
        else
          @app_id                 = app_id || Apps::WebrootApp.first.id
          @cred                   = Credential.find(cred_id)
          @events                 = events
          @customer               = @cred.account
          # e.g. /service/api/console/gsm/#{@cred.webroot_gsm_key}/sites/#{site}/threathistory
          @site = source_guid&.split("sites/")&.last&.split("/threathistory")&.first
          customer_id = AntivirusCustomerMap.find_by(app_id: app_id, antivirus_id: @site)&.account_id
          @account = customer_id.nil? ? @cred.account : Account.find(customer_id)

          # TODO: make sure this is an accout in the right MSP
        end
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        return if @events.blank? || @cred.nil?

        @events.each do |event|
          digest = Digest::MD5.hexdigest(event.to_s)
          next if existing_records.where(external_id: digest).exists?

          event["is_paying"] = matching_hostname?(event["HostName"])
          event["site"] = @site
          result = result(event, digest)

          ServiceRunnerJob.perform_later("Apps::Results::Processor", result) if result.save
        end
      end

      private

      def existing_records
        ::Apps::Result.where(app_id: @app_id, customer_id: @account.id)
      end

      def formatted_event(event)
        event["Status"] = event.dig("LastSeen").nil? ? "Quarantined" : "Remediated"
        {
          "type"       => "Webroot",
          "attributes" => event
        }
      end

      def result(event, digest)
        ::Apps::WebrootResult.new(
          app_id:         @app_id,
          detection_date: (event.dig("FirstSeen") || DateTime.current).to_datetime,
          value:          CGI.unescape(event.dig("FileName")),
          value_type:     "",
          customer_id:    @account.id,
          details:        formatted_event(event),
          credential_id:  @cred.id,
          verdict:        "suspicious",
          account_path:   @account.path,
          external_id:    digest
        )
      end

      def app_config
        @app_config ||= Apps::AccountConfig.joins(:account).where(
          type: "Apps::AccountConfig", account_id: @customer.self_and_ancestors.select(:id),
          app_id: @app_id
        ).order("accounts.path DESC").first&.merged_config || {}
      end
    end
  end
end
