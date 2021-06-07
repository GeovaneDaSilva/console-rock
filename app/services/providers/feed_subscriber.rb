module Providers
  # Subscribe to feeds for new provider
  class FeedSubscriber
    def initialize(provider)
      @provider = provider
    end

    def call
      refresh_feed_results!
    end

    private

    def group
      @group ||= @provider.groups.required.first
    end

    def feed
      @feed ||= Hunts::Feed.create(group: group, source: :system_hunts)
    end

    def refresh_feed_results!
      ServiceRunnerJob.perform_later(updater_class_name, feed)
    end

    def updater_class_name
      "Hunts::Feeds::#{feed.source.camelize}"
    end
  end
end
