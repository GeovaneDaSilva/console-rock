module Hunts
  module Feeds
    # Update all hunt feeds
    class Updater
      ALL = %i[cymon alien_vault reversing_labs virus_total system_hunts].freeze

      def initialize(type = nil)
        @type = type
      end

      def call
        return
        if @type.nil?
          all
        else
          send(@type.to_sym)
        end
      end

      private

      def all
        ALL.each { |meth| send(meth) }
      end

      def cymon
        Hunts::Feed.cymon.find_each do |feed|
          ServiceRunnerJob.perform_later("Hunts::Feeds::Cymon", feed)
        end
      end

      def alien_vault
        Hunts::Feed.alien_vault.find_each do |feed|
          ServiceRunnerJob.perform_later("Hunts::Feeds::AlienVault", feed)
        end
      end

      def reversing_labs
        Hunts::Feed.reversing_labs.find_each do |feed|
          ServiceRunnerJob.perform_later("Hunts::Feeds::ReversingLabs", feed)
        end
      end

      def virus_total
        Hunts::Feed.virus_total.find_each do |feed|
          ServiceRunnerJob.perform_later("Hunts::Feeds::VirusTotal", feed)
        end
      end

      def system_hunts
        Hunts::Feed.system_hunts.find_each do |feed|
          ServiceRunnerJob.perform_later("Hunts::Feeds::SystemHunts", feed)
        end
      end
    end
  end
end
