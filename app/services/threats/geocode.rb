module Threats
  UngeocodeableError = Class.new(StandardError)

  # Creates a GeocodedThreat record if value can be geocoded
  class Geocode
    def initialize(value, account, threatable)
      @value      = value
      @account    = account
      @threatable = threatable
    end

    def call
      return if private?
      return unless result

      ServiceRunnerJob.set(queue: "ui").perform_later(
        "Broadcasts::Threats::Geocoded", geocoded_threat
      )

      geocoded_threat
    rescue Resolv::ResolvError
      # Rails.logger.info("Unable to resolve #{@value} for geocoding")
      nil
    rescue UngeocodeableError, ActiveRecord::RecordInvalid
      # Rails.logger.info("Unable to geocode #{@value}")
      nil
    end

    private

    def geocoded_threat
      @geocoded_threat ||= GeocodedThreat.create!(
        geocoded_attrs.merge(
          value:          @value,
          account:        @account,
          threatable:     @threatable,
          detection_date: @threatable.try(:detection_date) || DateTime.current
        )
      )
    end

    def geocoded_attrs
      {
        city:      city,
        country:   country,
        latitude:  latitude,
        longitude: longitude
      }
    rescue NoMethodError
      raise UngeocodeableError
    end

    def ip
      @ip ||= Resolv.getaddress @value
    end

    def result
      @result ||= CachedIp.find(ip) || Geocoder.search(ip, ip_address: true).first
    end

    def country
      result.try(:country) || result.try(:country_code)
    end

    def city
      result.try(:city)
    end

    def latitude
      location.try(:[], 0)
    end

    def longitude
      location.try(:[], 1)
    end

    def location
      result.try(:loc)&.split(",") || [result&.latitude, result&.longitude]
    end

    def private?
      IPAddr.new(ip).private?
    end
  end
end
