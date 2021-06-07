module Hunts
  module Feeds
    module Converters
      # :nodoc
      class AlienVault < Base
        private

        def tests
          @tests ||= indicators.collect do |indicator|
            test_for(indicator["type"], indicator["indicator"])
          end.compact
        end

        def test_for(type, value)
          case type
          when "URL"
            browser_visit_test(value, :is_equal_to)
          when "domain"
            browser_visit_test(value, :contains)
          when "hostname"
            network_connection_test(value)
          when "IPv4"
            network_connection_test(value)
          when "FileHash-MD5", "FileHash-SHA1", "FileHash-SHA256"
            file_hash_test(value)
          when "YARA"
            yara_test(value)
            # else
            # Rails.logger.info(
            #   "Unknown indicator type: #{type} for Feed Result: #{@feed_result.id}, #{value}"
            # )

            # nil
          end
        end
      end
    end
  end
end
