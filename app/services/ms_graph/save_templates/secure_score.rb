# :nodoc
module MsGraph
  # :nodoc
  module SaveTemplates
    # :nodoc
    class SecureScore
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
          next if existing_overall_score_results.include?(event["createdDateTime"])

          overall_score_result = overall_score_result(event)

          if overall_score_result.save
            ServiceRunnerJob.perform_later("Apps::Results::Processor", overall_score_result)
          end
        end

        event = @events.first

        event.fetch("controlScores", []).each do |control_score|
          next if control_score["NotScored"] == "true"
          next if app_config.fetch("exclusions", []).include?(control_score["controlName"])

          unless ref_secure_scores.include?(control_score["controlName"])
            MsGraph::Services::MakeRefSecureScore.new(
              @ms_graph_credential_id, control_score["controlName"]
            ).call
          end

          next if existing_results[control_score["controlName"]] == control_score["score"]

          control_score_result = control_score_result(event, control_score)

          if control_score_result.save
            ServiceRunnerJob.perform_later("Apps::Results::Processor", control_score_result)
            result_ids << control_score_result.id
          end
        end
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

      def existing_results
        @existing_results ||= Apps::Result.where(
          app_id: @app_id, customer: @customer
        ).where.not(value: "overallScore").pluck(
          :value, :details
        ).collect { |value, details| [value, details["score"]] }.to_h
      end

      def existing_overall_score_results
        @existing_overall_score_results ||= Apps::Result.where(
          app_id: @app_id, customer: @customer, value: "overallScore"
        ).pluck(:detection_date)
      end

      def ref_secure_scores
        @ref_secure_scores ||= RefSecureScore.pluck(:id)
      end

      def custom_config
        @custom_config ||= Apps::CustomConfig.joins(:account).where(
          type: "Apps::CustomConfig", account_id: @customer.self_and_ancestors.select(:id),
          app_id: @app_id
        ).order("accounts.path DESC").first || {}
      end

      def overall_score_result(event)
        Apps::Office365Result.new(
          app_id:         @app_id,
          detection_date: event["createdDateTime"],
          value:          "overallScore",
          value_type:     "SecureScoreOveralScore",
          customer:       @customer,
          details:        {
            azureTenantId:            event["azureTenantId"],
            activeUserCount:          event["activeUserCount"],
            currentScore:             event["currentScore"],
            enabledServices:          event["enabledServices"],
            licensedUserCount:        event["licensedUserCount"],
            maxScore:                 event["maxScore"],
            numericalScore:           (event["currentScore"] / event["maxScore"]),
            averageComparativeScores: event["averageComparativeScores"],
            controlName:              "overallScore",
            controlCategory:          "Summary",
            score:                    "#{event['currentScore']} / #{event['maxScore']}"
          },
          credential_id:  @ms_graph_credential_id,
          verdict:        "informational",
          account_path:   @customer.path
        )
      end

      def control_score_result(event, control_score)
        Apps::Office365Result.new(
          app_id:         @app_id,
          detection_date: event["createdDateTime"].to_datetime,
          value:          control_score["controlName"],
          value_type:     "SecureScoreControlScore",
          customer:       @customer,
          details:        control_score,
          account_path:   @customer.path,
          credential_id:  @ms_graph_credential_id,
          verdict:        "informational"
        )
      end
    end
  end
end
