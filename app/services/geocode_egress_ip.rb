# Geocode an EgressIP instance
class GeocodeEgressIp
  def initialize(egress_ip)
    @egress_ip = egress_ip
  end

  def call
    @egress_ip.tap do |record|
      record.geocode
      record.save
    end
  end
end
