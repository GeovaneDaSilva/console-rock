module Hunts
  module Feeds
    # :nodoc
    class VirusTotal
      def initialize(feed)
        @feed = feed
      end

      def call
        return
        hashes.each do |hash|
          feed_result = Builders::VirusTotal.new(@feed, hash).call
          Converters::VirusTotal.new(feed_result).call unless feed_result.hunt
        end

        ServiceRunnerJob.perform_later(
          "DeviceBroadcasts::Group", @feed.group,
          { type: "hunts" }.to_json
        )

        @feed.update(last_refreshed: DateTime.current)
      end

      private

      def hashes
        if response.status == 200 && response.body["response_code"] == 1
          response.body["hashes"]
        else
          {}
        end
      end

      def response
        @response ||= client.get(uri)
      end

      def client
        @client ||= ApiClients::VirusTotal.new.call
      end

      def uri
        "file/search?apikey=#{@feed.account.nearest_virus_total_api_key}&query=#{query}"
      end

      def query
        @feed.keyword
      end
    end
  end
end
