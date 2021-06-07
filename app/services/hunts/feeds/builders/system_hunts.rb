module Hunts
  module Feeds
    module Builders
      # :nodoc
      class SystemHunts
        def initialize(feed, system_hunt)
          @feed        = feed
          @system_hunt = system_hunt
        end

        def call
          @feed_result = @feed.feed_results.find(id)
        rescue ActiveRecord::RecordNotFound
          @feed_result = @feed.feed_results.new(id: id)
        ensure
          attrs = @feed_result.new_record? ? new_result_attrs : result_attrs
          @feed_result.update(attrs)
          @feed_result
        end

        private

        def new_result_attrs
          { author_name: I18n.t("application.name") }.merge(result_attrs)
        end

        def result_attrs
          {
            title:       @system_hunt.name,
            description: @system_hunt.description,
            timestamp:   @system_hunt.updated_at,
            indicators:  [@system_hunt.id]
          }
        end

        def id
          [@feed.id, @feed.source, @system_hunt.id].reject(&:blank?).join("-")
        end
      end
    end
  end
end
