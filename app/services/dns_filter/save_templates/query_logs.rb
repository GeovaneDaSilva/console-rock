# :nodoc
module DnsFilter
  # :nodoc
  module SaveTemplates
    # :nodoc
    class QueryLogs
      def initialize(app_id, credential, data_json)
        @app_id     = app_id
        @credential = credential
        @data_json  = data_json
      end

      def call
        return if @data_json.blank?

        data = JSON.parse(@data_json)

        case app_config.dig("save_type")
        when "Route Detections to Customers Using AV Site IDs"
          accounts = Account.where(id: data.keys)
          (accounts || []).each do |account|
            query_logs = data[account.id.to_s]
            process_query_logs(account, query_logs)
          end
        else
          account = Account.find_by(id: app_config.dig("target_customer")) || @credential.account
          query_logs = data.values.flatten
          process_query_logs(account, query_logs)
        end
      end

      private

      def app_config
        @app_config ||= Apps::AccountConfig.where(
          app_id:     @app_id,
          account_id: @credential.account_id
        ).first&.merged_config || {}
      end

      def existing_app_results(account)
        @existing_app_results ||= account.all_descendant_dns_filter_results.pluck(:external_id)
      end

      def existing_result?(account, digest)
        existing_app_results(account).include?(digest)
      end

      def process_query_logs(account, query_logs)
        return if query_logs.blank?

        query_logs.each do |query_log|
          next if query_log.blank?

          digest = Digest::MD5.hexdigest(query_log.to_s)
          next if existing_result?(account, digest)

          app_result = build_app_result(account, query_log, digest)
          ServiceRunnerJob.perform_later("Apps::Results::Processor", app_result) if app_result.save
        end
      end

      def build_app_result(account, query_log, digest)
        ::Apps::DnsFilterResult.new(
          app_id:         @app_id,
          detection_date: (query_log.dig("time") || DateTime.current).to_datetime,
          value:          query_log.dig("agentname"),
          value_type:     query_log.dig("agenttype"),
          customer_id:    account.id,
          details:        { "type" => "DNSFilter", "attributes" => query_log },
          credential_id:  @credential.id,
          verdict:        :suspicious,
          account_path:   account.path,
          external_id:    digest
        )
      end
    end
  end
end
