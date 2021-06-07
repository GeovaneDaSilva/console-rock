# :nodoc
module MsGraph
  # :nodoc
  module Services
    # :nodoc
    class AddGeocodedThreat
      def initialize(result)
        @result = result
      end

      def call
        return if @result.nil?

        GeocodedThreat.new(
          value:           @result.details.location.dig("ip_address"),
          threatable_type: "Apps::Result",
          threatable_id:   @result.id.to_s,
          city:            @result.details.location.dig("city"),
          country:         @result.details.location.dig("countryOrRegion"),
          latitude:        @result.details.location.dig("latitude"),
          longitude:       @result.details.location.dig("longitude"),
          account_id:      @result.customer_id,
          detection_date:  @result.detection_date
        ).save
      end
    end
  end
end
