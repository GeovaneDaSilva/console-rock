module Hunts
  module Feeds
    module Builders
      # :nodoc
      class VirusTotal
        def initialize(feed, hash)
          @feed = feed
          @hash = hash
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
            author_name: "VirusTotal",
            title:       title,
            description: description,
            timestamp:   details.dig("scan_date"),
            indicators:  details
          }
        end

        def id
          [@feed.id, @feed.source, @hash].reject(&:blank?).join("-")
        end

        def title
          details.dig("additional_info", "exiftool", "ProductName") || "Unknown"
        end

        def description
          [
            details.fetch("submission_names", []).take(10).join(", "),
            details.dig("additional_info", "magic"),
            details.dig("additional_info", "exiftool", "CompanyName"),
            details.dig("additional_info", "exiftool", "ObjectFileType")
          ].reject(&:blank?).join(" ")
        end

        def details
          if response.status == 200 && response.body["response_code"] == 1
            response.body
          else
            {}
          end
        end

        def response
          @response ||= client.get(uri)
        end

        def client
          @client ||= ApiClients::VirusTotal.new.call
        end

        def uri
          "file/report?apikey=#{@feed.account.nearest_virus_total_api_key}&resource=#{@hash}&allinfo=true"
        end
      end
    end
  end
end
