# :nodoc
module MsGraph
  # :nodoc
  module SaveTemplates
    # :nodoc
    class RiskDetection
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
          next if existing_result?(event)

          result = result(event)

          if result.save
            ServiceRunnerJob.perform_later("Apps::Results::Processor", result)
            result_ids << result.id
          end
        end

        return if custom_config.blank?

        ServiceRunnerJob.perform_later(
          "Apps::Results::CustomDestroyer", custom_config.id, custom_config.account_id, custom_config.app_id
        )
      end

      private

      def existing_result?(event)
        existing_results.where(
          detection_date: event["activityDateTime"],
          value:          event["activity"]
        ).exists?
      end

      def existing_results
        @existing_results ||= Apps::Result.where(app_id: @app_id, customer: @customer)
      end

      def result(event)
        Apps::Office365Result.new(
          app_id:         @app_id,
          detection_date: event["activityDateTime"].to_datetime,
          value:          event["activity"],
          value_type:     "activityDisplayName",
          customer:       @customer,
          account_path:   @customer.path,
          credential_id:  @ms_graph_credential_id,
          verdict:        "informational",
          details:        organize(event),
          external_id:    "#{event['activityDateTime']}-#{event['activity']}"
        )
      end

      def verdict(event)
        case event["riskLevel"]
        when "low"
          "informational"
        when "medium"
          "suspicious"
        when "high"
          "malicious"
        else
          "informational"
        end
      end

      def organize(event)
        {
          description:         event["riskDetail"],
          time:                event["activityDateTime"],
          result:              event["result"],
          resultReason:        event["resultReason"],
          loggingService:      event["loggedByService"],
          riskEventType:       event["riskEventType"],
          riskState:           event["riskState"],
          riskLevel:           event["riskLevel"],
          riskDetail:          event["riskDetail"],
          source:              event["source"],
          detectionTimingType: event["detectionTimingType"],
          activity:            event["activity"],
          tokenIssuerType:     event["tokenIssuerType"],
          ipAddress:           event["ipAddress"],
          userDisplayName:     event["userDisplayName"],
          userPrincipalName:   event["userPrincipalName"],
          detectedDateTime:    event["detectedDateTime"],
          location:            event["location"],
          additionalInfo:      parse_additional_info(event["additionalInfo"])
        }
      end

      def parse_additional_info(str)
        return if str.nil?

        info = JSON.parse(str)
        if info.size == 1
          info.first
        else
          info
        end
      end

      def custom_config
        @custom_config ||= Apps::CustomConfig.joins(:account).where(
          type: "Apps::CustomConfig", account_id: @customer.self_and_ancestors.select(:id),
          app_id: @app_id
        ).order("accounts.path DESC").first || {}
      end
    end
  end
end
