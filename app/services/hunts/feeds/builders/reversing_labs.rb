module Hunts
  module Feeds
    module Builders
      # :nodoc
      class ReversingLabs
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
            author_name: "ReversingLabs",
            title:       description,
            description: description,
            timestamp:   @result["record_on"],
            indicators:  @result
          }
        end

        def id
          [@feed.id, @feed.source, result_hash].reject(&:blank?).join("-")
        end

        def description
          [
            Hunts::Feed::REVERSINGLABS_KEYWORD_MAP[@feed.keyword],
            @result["family_name"]
          ].reject(&:blank?).join(" - ")
        end

        def result_hash
          Digest::MD5.new.tap { |digest| digest.update @result.to_json }.hexdigest
        end
      end
    end
  end
end
