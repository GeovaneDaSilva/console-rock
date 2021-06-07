require "httpi"

# :nodoc
module MsGraph
  # :nodoc
  module SaveTemplates
    # :nodoc
    class Signin
      def initialize(app_id, ms_graph_credential_id, customer, events)
        @app_id                 = app_id
        @ms_graph_credential_id = ms_graph_credential_id
        @customer               = customer
        @events                 = events
        @domains                = Credential.find_by(id: ms_graph_credential_id).ms_base_domains
        @domains ||= pull_domains
        # @last_result            = last_result
      end

      def call
        return if @events.blank?

        # @last_result.destroy_all if @last_result.any?
        result_ids = []

        @events.each do |event|
          next if skip_account?(event["userPrincipalName"])
          next if excluded_ips.include?(event["ipAddress"])
          next unless event["userPrincipalName"].include?("@")
          next if excluded_emails.include?(event["userPrincipalName"])
          next if report_only_successful_logins && !event["status"]["errorCode"].zero?

          domain = event["userPrincipalName"].split("@").last
          next unless @domains.include?(domain)

          event["location"]["countryOrRegion"]&.upcase! # Excluded countries upcased

          if !report_all_failed_logins || event["status"]["errorCode"].zero?
            next if excluded_countries.include?(event.dig("location", "countryOrRegion"))
          end

          digest = Digest::MD5.hexdigest(event.to_s)

          next if existing_result?(digest)

          event["location"]["city"]&.capitalize!
          event["createdDateTime"] = DateTime.current if event["createdDateTime"].blank?

          result = result(event, digest)
          next unless result.save

          ServiceRunnerJob.set(queue: :threat_evaluation)
                          .perform_later("MsGraph::Services::IpLookup", result)
          result_ids << result.id
        end

        # ServiceRunnerJob.perform_later(
        #   "MsGraph::Services::UpdateLastPull", @customer.id, @app_id, DateTime.current.to_json
        # )
        return if custom_config.blank?

        ServiceRunnerJob.perform_later(
          "Apps::Results::CustomDestroyer", custom_config.id, custom_config.account_id, custom_config.app_id
        )
      end

      private

      def excluded_ips
        @excluded_ips ||= app_config.fetch(
          "signin_excluded_ips", APP_CONFIGS[:office365_signin][:signin_excluded_ips]
        )
      end

      def excluded_countries
        @excluded_countries ||= app_config.fetch(
          "signin_excluded_countries", APP_CONFIGS[:office365_signin][:signin_excluded_countries]
        ).select { |_k, v| v.dig("enabled") }
      end

      def excluded_emails
        @excluded_emails ||= app_config.fetch("exclusions", [])
      end

      def report_all_failed_logins
        @report_all_failed_logins ||= app_config.fetch(
          "signin_report_all_failed_logins", APP_CONFIGS[:office365_signin][:signin_report_all_failed_logins]
        )
      end

      def report_only_successful_logins
        @report_only_successful_logins ||= app_config.fetch(
          "signin_report_only_successful_logins",
          APP_CONFIGS[:office365_signin][:signin_report_only_successful_logins]
        )
      end

      def app_config
        @app_config ||= Apps::AccountConfig.joins(:account).where(
          type: "Apps::AccountConfig", account_id: @customer.self_and_ancestors.select(:id),
          app_id: @app_id
        ).order("accounts.path DESC").first&.merged_config || {}
      end

      def custom_config
        @custom_config ||= Apps::CustomConfig.joins(:account).where(
          type: "Apps::CustomConfig", account_id: @customer.self_and_ancestors.select(:id),
          app_id: @app_id
        ).order("accounts.path DESC").first || {}
      end

      def existing_result?(digest)
        existing_records.where(external_id: digest).exists?
      end

      def existing_records
        Apps::Result.where(app_id: @app_id, customer_id: @customer.id)
      end

      # def last_result
      #   existing_records.malicious.where("details ->> 'type' = 'MsGraphError'")
      # end

      def skip_account?(user)
        skip_account_list.where(external_id: user).any?
      end

      def skip_account_list
        @skip_account_list ||= BillableInstance.where(
          account_path:   @customer.path,
          line_item_type: "office_365_mailbox",
          active:         false
        )
      end

      def result(event, digest)
        Apps::Office365Result.new(
          app_id:         @app_id,
          detection_date: event["createdDateTime"].to_datetime,
          value:          "#{event['location']['city']}, #{event['location']['countryOrRegion']}",
          value_type:     "SignInLocation",
          customer:       @customer,
          details:        event,
          credential_id:  @ms_graph_credential_id,
          verdict:        "informational",
          account_path:   @customer.path,
          external_id:    digest
        )
      end

      def pull_domains
        credential = Credential.find_by(id: @ms_graph_credential_id)
        MsGraph::Services::PullDomains.new(credential).call
      end
    end
  end
end
