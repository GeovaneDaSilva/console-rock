# Fixes BaseUrls for Syncro Credentials not using full url links
module Integrations
  module Syncro
    # Ping an API endpoint
    class FixBaseUrls
      BATCH_SIZE = 25

      def initialize
        @total = Credentials::Syncro.count
        @affected = 0
      end

      def call
        start_text
        process
        end_text
      end

      private

      def process
        batch_total = (@total / BATCH_SIZE.to_f).ceil
        ActiveRecord::Base.transaction do
          Credentials::Syncro.find_in_batches(batch_size: BATCH_SIZE).each_with_index do |batch, index|
            collected = collect_updates(batch)
            Credentials::Syncro.update(collected.keys, collected.values)
            @affected += collected.keys.size
            log("\t-processing batch # #{index + 1}/#{batch_total}")
          end
        end
      end

      def collect_updates(batch)
        batch.collect do |cred|
          next if cred.base_url =~ /\A(http|https)?:\/\/[a-zA-Z0-9\-\.]+\.[a-z]{2,4}/

          [cred.id, { base_url: "https://#{cred.base_url}.syncromsp.com/api/v1" }]
        end.compact.to_h
      end

      def start_text
        log("#{Time.current} - Starting Syncro FixBaseUrls...\r\n\n")
        log("\t-No. of Syncro Credentials: #{@total}")
      end

      def end_text
        log("\t-Total Records Affected: #{@affected}\r\n\n")
        log("-#{Time.current} - End Script")
      end

      def log(msg)
        Rails.logger.info(msg)
      end
    end
  end
end
