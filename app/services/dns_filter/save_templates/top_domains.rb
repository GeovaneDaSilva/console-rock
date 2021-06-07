# :nodoc
module DnsFilter
  # :nodoc
  module SaveTemplates
    # :nodoc
    class TopDomains
      def initialize(app_id, credential, data_json)
        @app_id     = app_id
        @credential = credential
        @data_json  = data_json
        @account    = credential.account
      end

      def call
        return if @data_json.blank?

        data = JSON.parse(@data_json)
        data.each do |account_id, query_logs|
          account = Account.find(account_id)
          process_query_logs(account, query_logs)
        end
      end

      private

      def existing_app_results
        @account.all_descendant_dns_filter_results
      end

      def process_query_logs(account, query_logs)
        return if query_logs.blank?

        query_logs.each do |query_log|
          next if query_log.blank?

          digest = Digest::MD5.hexdigest(query_log.to_s)
          next if existing_app_results.where(external_id: digest).exists?

          app_result = build_app_result(account, query_log, digest)
          ServiceRunnerJob.perform_later("Apps::Results::Processor", app_result) if app_result.save
        end
      end

      def build_app_result(account, query_log, digest)
        ::Apps::DnsFilterResult.new(
          app_id:         @app_id,
          detection_date: DateTime.current,
          value:          query_log.dig("domain"),
          value_type:     query_log.dig("policies_names").join(", "),
          customer_id:    account&.id,
          details:        { "type" => "DNSFilter", "attributes" => query_log },
          credential_id:  @credential.id,
          verdict:        :suspicious,
          account_path:   account&.path,
          external_id:    digest
        )
      end
    end
  end
end
