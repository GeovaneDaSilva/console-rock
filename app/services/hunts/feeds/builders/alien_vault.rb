module Hunts
  module Feeds
    module Builders
      # :nodoc
      class AlienVault
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
            author_name: @result["author_name"],
            title:       @result["name"],
            description: description,
            timestamp:   @result["modified"],
            indicators:  @result["indicators"]
          }
        end

        def id
          [@feed.id, @feed.source, @result["id"]].reject(&:blank?).join("-")
        end

        def description
          [
            @result["description"], @result.fetch("tags", []).join(", ")
          ].reject(&:blank?).join(" Tags: ")
        end
      end
    end
  end
end
