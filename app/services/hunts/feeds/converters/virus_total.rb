module Hunts
  module Feeds
    module Converters
      # :nodoc
      class VirusTotal < Base
        private

        def tests
          @tests ||= [test].compact
        end

        def test
          return file_hash_test(indicators["md5"]) if indicators["md5"]
        end
      end
    end
  end
end
