module Hunts
  module Feeds
    module Converters
      # :nodoc
      class Base
        def initialize(feed_result)
          @feed_result = feed_result
        end

        def call
          hunt.save!

          hunt
        end

        private

        def hunt
          @hunt ||= Hunt.new(
            name:        name,
            group:       @feed_result.feed.group,
            tests:       tests,
            feed_result: @feed_result,
            matching:    :any_test
          )
        end

        def name
          [@feed_result.title, @feed_result.author_name]
            .join(" - ")
            .exclude_invalid_characters!
        end

        def tests
          raise NotImplementedError
        end

        def network_connection_test(condition)
          Hunts::NetworkConnectionTest.new(
            conditions: [
              Hunts::IpAddressCondition.new(operator: :exists, condition: condition)
            ]
          )
        end

        def browser_visit_test(condition, operator = :contains)
          Hunts::BrowserVisitTest.new(
            conditions: [
              Hunts::LikeCondition.new(operator: operator, condition: condition)
            ]
          )
        end

        def file_hash_test(condition)
          Hunts::FileHashTest.new(
            conditions: [
              Hunts::EqualityCondition.new(operator: :is_equal_to, condition: condition)
            ]
          )
        end

        def yara_test(condition)
          upload = upload_for(condition)

          Hunts::YaraTest.new(
            conditions: [
              Hunts::EqualityCondition.new(operator: :is_equal_to, condition: %(%SYSTEMDRIVE%), order: 1),
              Hunts::YaraUploadCondition.new(operator: :is_equal_to, condition: upload.id, order: 2)
            ]
          )
        end

        def upload_for(text)
          Uploads::Builder.new(
            temp_file_for(text).path,
            sourceable: @feed_result.feed.group.account.root,
            filename:   "yara_test.rul"
          ).call
        end

        def temp_file_for(text)
          Tempfile.new.tap do |f|
            f.write(text)
          end
        end

        def indicators
          @feed_result.indicators
        end
      end
    end
  end
end
