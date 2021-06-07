# Redis backed panics
class Panic < RedisRecord
  def device
    @device ||= Device.find(device_id)
  rescue ActiveRecord::RecordNotFound
    OpenStruct.new(hostname: device_id, id: "none", customer_id: "none")
  end
end
