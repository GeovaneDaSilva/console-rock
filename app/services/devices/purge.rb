module Devices
  # Purge device of all app results, geocoded threats, and hunt results
  class Purge
    def initialize(key, device)
      @key = key
      @device = device
    end

    def call
      purge_app_results!
      purge_threats!
      purge_hunt_results!

      Rails.cache.write(@key, "completed")
    end

    private

    def purge_app_results!
      @device.app_results.destroy_all
    end

    def purge_threats!
      @device.hunted_geocoded_threats.destroy_all
    end

    def purge_hunt_results!
      @device.hunt_results.destroy_all
    end
  end
end
