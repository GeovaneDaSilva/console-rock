# IP address of devices emitting reports
class EgressIp < ApplicationRecord
  belongs_to :customer
  has_many :devices, dependent: :nullify

  validates :ip, uniqueness: { scope: :customer_id }

  after_update :touch_devices
  after_commit :queue_geocode, if: :needs_geocode?

  scope :with_devices, -> { where("devices_count > 0") }

  geocoded_by :ip do |record, results|
    result = results.first

    if result
      %w[latitude longitude city state country].each do |meth|
        record.send("#{meth}=", result.send(meth))
      end
    end
  end

  # Is it a loopback IP address?
  def loopback?
    IPAddress(ip).loopback?
  end

  def location
    [city, state].reject(&:blank?).join(", ")
  end

  def private_ip?
    [
      IPAddr.new("10.0.0.0/8"),
      IPAddr.new("172.16.0.0/12"),
      IPAddr.new("192.168.0.0/16"),
      IPAddr.new("fd00::/8")
    ].collect { |range| range.include?(ip) }.include?(true)
  end

  private

  def needs_geocode?
    !loopback? && previous_changes[:ip].present? && !private_ip?
  end

  def touch_devices
    devices.update_all(updated_at: Time.current)
  end

  def queue_geocode
    ServiceRunnerJob.perform_later("GeocodeEgressIp", self)
  end
end
