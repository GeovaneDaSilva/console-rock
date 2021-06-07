module Hunts
  module Feeds
    module Converters
      # :nodoc
      class SystemHunts < Base
        private

        def hunt
          @hunt ||= new_or_created_hunt
        end

        def tests
          @tests ||= system_hunt.tests_for_revision.collect do |test_template|
            test = test_template.dup
            test.conditions = test_template.conditions.collect(&:dup)
            test.revision = system_hunt.revision

            test
          end
        end

        def system_hunt
          @system_hunt ||= Hunt.system_hunt_feeds.find(indicators.first)
        end

        def new_or_created_hunt
          @hunt = @feed_result.hunt || Hunt.new

          new_hunt = !@hunt.persisted?
          changing_revision = @hunt.revision != system_hunt.revision

          @hunt.update(hunt_attrs)
          @hunt.tests << tests if changing_revision || new_hunt
          @hunt.save

          @hunt
        end

        def hunt_attrs
          {
            name:        [@feed_result.title, @feed_result.author_name].join(" - "),
            group:       @feed_result.feed.group,
            feed_result: @feed_result,
            matching:    system_hunt.matching,
            revision:    system_hunt.revision,
            continuous:  system_hunt.continuous,
            indicator:   system_hunt.indicator
          }
        end
      end
    end
  end
end
