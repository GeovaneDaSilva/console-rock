module Hunts
  module Feeds
    # :nodoc
    class AlienVault
      def initialize(feed)
        @feed = feed
      end

      def call
        return
        results.each do |result|
          feed_result = Builders::AlienVault.new(@feed, result).call
          Converters::AlienVault.new(feed_result).call unless feed_result.hunt
        end

        @feed.update(last_refreshed: DateTime.current)
      end

      private

      def client
        @client ||= ApiClients::AlienVault.new(
          api_key: api_key
        ).call
      end

      def results
        @results ||= gather_results
      end

      def gather_results
        results = []
        next_url = "/api/v1/pulses/subscribed?modified_since=#{modified_since}&limit=10&page=1"

        while next_url
          response = client.get(next_url)

          next_url = response.body["next"]
          results += response.body["results"].to_a
        end

        results
      rescue Faraday::Error
        Rails.logger.error("Problem updating feed id: #{@feed.id}")
        results.to_a
      end

      def api_key
        @feed.group.account.nearest_alien_vault_api_key
      end

      def modified_since
        @modified_since ||= (@feed.last_refreshed || 7.days.ago).utc.iso8601
      end
    end
  end
end
