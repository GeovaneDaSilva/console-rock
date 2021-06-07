module Hunts
  module Feeds
    # :nodoc
    class Cymon
      def initialize(feed)
        @feed = feed
      end

      def call
        return
        results.each do |result|
          feed_result = Builders::Cymon.new(@feed, result).call
          Converters::Cymon.new(feed_result).call unless feed_result.hunt
        end

        @feed.update(last_refreshed: @last_refreshed)
      end

      private

      def request
        @request ||= HTTPI.get(
          HTTPI::Request.new(
            "https://api.cymon.io/v2/ioc/search/term/#{@feed.keyword}"
          )
        )
      end

      def results
        []
      end
    end
  end
end
