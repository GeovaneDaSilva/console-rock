# :nodoc
module MsGraph
  # :nodoc
  module SaveTemplates
    # :nodoc
    class EmailRules
      def initialize(app_id, credential_id, customer, events, email)
        @app_id                 = app_id
        @credential             = Credential.find(credential_id)
        @customer               = customer
        @events                 = events
        @target_addresses       = {}
        @email                  = email
        @domains                = @credential.ms_base_domains || pull_domains
      rescue ActiveRecord::RecordNotFound
        @credential = nil
      end

      def call
        return if @events.blank? || @credential.nil?

        result_ids = []
        @events.each do |event|
          next unless event.dig("actions")
          next unless event.dig("actions").keys.any? { |action| valid_types.include?(action) }
          next unless seriousness(event) == :malicious
          next if existing_result?(event.dig("id"))

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

      def valid_types
        %w[forwardAsAttachmentTo redirectTo forwardTo]
      end

      def existing_result?(external_id)
        existing_results.where(external_id: external_id).exists?
      end

      # Rails 5.1+ has fixed any and exists so they are equally performant
      def existing_results
        Apps::Result.where(app_id: @app_id, customer: @customer)
      end

      def result(event)
        Apps::Office365Result.new(
          app_id:         @app_id,
          detection_date: DateTime.current,
          value:          "forwarding to #{target_address(event)}",
          value_type:     "activityDisplayName",
          customer:       @customer,
          account_path:   @customer.path,
          credential_id:  @credential.id,
          verdict:        seriousness(event),
          details:        organize(event),
          external_id:    event.dig("id")
        )
      end

      def organize(event)
        event.merge(
          {
            created_by:      @email,
            activity:        {
              description: "Email forwarding to #{target_address(event)}",
              result:      event.dig("displayName")
            },
            targetResources: { type: "email_forwarding_rule" },
            verdict:         seriousness(event)
          }
        )
      end

      def target_address(event)
        return @target_addresses[event.dig("id")] unless @target_addresses[event.dig("id")].nil?

        key = (event.dig("actions").keys & valid_types).first
        @target_addresses[event.dig("id")] = event.dig("actions", key)
                                                  .map { |n| n.dig("emailAddress", "address") }.join(", ")
        # TODO: need to figure out what to do with multiple forwards in same rule
      end

      def seriousness(event)
        @seriousness = {} if @seriousness.nil?
        id = event.dig("id")
        return @seriousness[id] if @seriousness[id]

        if target_address(event).include?("@")
          target_domain = target_address(event).split("@").last
          @seriousness[id] = @domains.include?(target_domain) ? :suspicious : :malicious
        elsif target_address(event).match("/OU=EXCHANGE ADMINISTRATIVE GROUP")
          @seriousness[id] = :suspicious
        else
          @seriousness[id] = :suspicious
        end
      end

      def pull_domains
        MsGraph::Services::PullDomains.new(@credential).call
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
