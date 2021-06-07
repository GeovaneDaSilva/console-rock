module Hunts
  module Feeds
    module Converters
      # :nodoc
      class ReversingLabs < Base
        private

        def tests
          @tests ||= [test].compact
        end

        def test
          return browser_visit_test(indicators["uri"], :is_equal_to) if indicators["uri"]
          return file_hash_test(indicators["md5"]) if indicators["md5"]
        end
      end
    end
  end
end
