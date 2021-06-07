module Hunts
  module Feeds
    module Converters
      # :nodoc
      class Cymon < Base
        private

        def tests
          @tests ||= indicators.keys.collect { |key| test_for_key(key) }
        end

        def test_for_key(key)
          case key
          when "url"
            browser_visit_test(indicators["url"], :is_equal_to)
          when "domain"
            browser_visit_test(indicators["domain"], :contains)
          when "hostname"
            network_connection_test(indicators["hostname"])
          when "ip"
            network_connection_test(indicators["ip"])
          when "md5"
            file_hash_test(indicators["md5"])
          when "sha1"
            file_hash_test(indicators["sha1"])
          when "sha256"
            file_hash_test(indicators["sha256"])
            # else
            # Rails.logger.info("Unknown indicator type: #{key} for Feed Result: #{@feed_result.id}")
          end
        end
      end
    end
  end
end
