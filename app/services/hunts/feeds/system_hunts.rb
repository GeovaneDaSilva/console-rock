module Hunts
  module Feeds
    # :nodoc
    class SystemHunts
      def initialize(feed)
        @feed = feed
      end

      def call
        return
        results.each do |result|
          feed_result = Builders::SystemHunts.new(@feed, result).call
          hunt = Converters::SystemHunts.new(feed_result).call

          hunt.update(disabled: result.disabled || excluded_ids.include?(result.id))
          feed_result.touch
        end
      end

      private

      def results
        Hunt.system_hunt_feeds
      end

      def excluded_ids
        @excluded_ids ||= @feed.system_hunts
      end
    end
  end
end
