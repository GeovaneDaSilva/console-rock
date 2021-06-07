module Hunts
  module Feeds
    module Builders
      # :nodoc
      class Cymon
        def initialize(feed, result)
          @feed   = feed
          @result = result
        end

        def call
          @feed_result = @feed.feed_results.find(id)
        rescue ActiveRecord::RecordNotFound
          @feed_result = @feed.feed_results.new(id: id)
        ensure
          @feed_result.update(result_attrs)
          @feed_result
        end

        private

        def result_attrs
          {
            author_name: @result["feed"],
            title:       @result["title"],
            description: [@result["title"], @result.fetch("tags", []).join(", ")].reject(&:blank?).join(". "),
            timestamp:   @result["timestamp"],
            indicators:  @result["ioc"]
          }
        end

        def id
          [@feed.id, @feed.source, @result["id"]].reject(&:blank?).join("-")
        end
      end
    end
  end
end
