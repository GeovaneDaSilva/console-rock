# :nodoc
module MsGraph
  # :nodoc
  module SaveTemplates
    # :nodoc
    class DirectoryAudit
      def initialize(app_id, ms_graph_credential_id, customer, events)
        @app_id                 = app_id
        @ms_graph_credential_id = ms_graph_credential_id
        @customer               = customer
        @events                 = events
      end

      def call
        return if @events.blank?

        result_ids = []
        @events.each do |event|
          next if skip_account?(event.dig("initiatedBy", "user", "userPrincipalName"))
          next if existing_result?(event)
          next if app_config.fetch("exclusions", []).include?(event["activityDisplayName"])

          result = result(event)

          if result.save
            ServiceRunnerJob.perform_later("Apps::Results::Processor", result)
            result_ids << result.id
          end
        end

        ServiceRunnerJob.perform_later(
          "MsGraph::Services::UpdateLastPull", @customer.id, @app_id, DateTime.current.to_json
        )
        return if custom_config.blank?

        ServiceRunnerJob.perform_later(
          "Apps::Results::CustomDestroyer", custom_config.id, custom_config.account_id, custom_config.app_id
        )
      end

      private

      def app_config
        @app_config ||= Apps::AccountConfig.joins(:account).where(
          type: "Apps::AccountConfig", account_id: @customer.self_and_ancestors.select(:id),
          app_id: @app_id
        ).order("accounts.path DESC").first&.merged_config || {}
      end

      def existing_result?(event)
        existing_results.where(
          detection_date: event["activityDateTime"],
          value:          event["activityDisplayName"]
        ).exists?
      end

      def existing_results
        Apps::Result.where(app_id: @app_id, customer: @customer)
      end

      def result(event)
        Apps::Office365Result.new(
          app_id:         @app_id,
          detection_date: event["activityDateTime"].to_datetime,
          value:          event["activityDisplayName"],
          value_type:     "activityDisplayName",
          customer:       @customer,
          account_path:   @customer.path,
          credential_id:  @ms_graph_credential_id,
          verdict:        "informational",
          details:        organize(event)
        )
      end

      def organize(event)
        {
          activity:        {
            description:    event["activityDisplayName"],
            time:           event["activityDateTime"],
            result:         event["result"],
            resultReason:   event["resultReason"],
            loggingService: event["loggedByService"]
          },
          targetResources: target_resources(event),
          initiatedBy:     initiated_by(event)
        }
      end

      def target_resources(event)
        return {} if event["targetResources"].first["modifiedProperties"].blank?

        event["targetResources"].first.reject { |_k, v| v.blank? }
      end

      def skip_account?(user_email)
        skip_account_list.where(external_id: user_email).any?
      end

      def skip_account_list
        @skip_account_list ||= BillableInstance.where(
          account_path:   @customer.path,
          line_item_type: "office_365_mailbox",
          active:         false
        )
      end

      def custom_config
        @custom_config ||= Apps::CustomConfig.joins(:account).where(
          type: "Apps::CustomConfig", account_id: @customer.self_and_ancestors.select(:id),
          app_id: @app_id
        ).order("accounts.path DESC").first || {}
      end

      def initiated_by(event)
        if event.dig("initiatedBy", "user").nil?
          {
            principalName: event.dig("initiatedBy", "app", "displayName"),
            ipOrService:   event.dig("initiatedBy", "app", "servicePrincipalId")
          }
        else
          {
            principalName: event.dig("initiatedBy", "user", "userPrincipalName"),
            ipOrService:   event.dig("initiatedBy", "user", "ipAddress")
          }
        end
      end
    end
  end
end
