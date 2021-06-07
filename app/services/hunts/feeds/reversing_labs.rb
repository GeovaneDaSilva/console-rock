module Hunts
  module Feeds
    # :nodoc
    class ReversingLabs
      def initialize(feed)
        @feed = feed
      end

      def call
        return
        results.each do |result|
          feed_result = Builders::ReversingLabs.new(@feed, result).call
          Converters::ReversingLabs.new(feed_result).call unless feed_result.hunt
        end

        @feed.update(last_refreshed: @last_refreshed)
      end

      private

      def results
        @last_refreshed = DateTime.current
        client.get(uri).body["rl"].values.first["entries"]
      rescue NoMethodError
        []
      end

      def client
        @client ||= ApiClients::ReversingLabs.new.call
      end

      def uri
        case @feed.keyword
        when /malware_apt/i
          "/api/feed/malware/detection/family/v2/query/apt/timestamp/#{modified_since}"
        when /malware_ransomware/i
          "/api/feed/malware/detection/family/v2/query/ransomware/timestamp/#{modified_since}"
        when /malware_exploits/i
          "/api/feed/malware/detection/family/v2/query/exploit/timestamp/#{modified_since}"
        when /network/i
          "/api/feed/malware_uri/v1/query/timestamp/#{modified_since}"
        end
      end

      def modified_since
        @modified_since ||= (@feed.last_refreshed || 7.days.ago).utc.to_i
      end
    end
  end
end
