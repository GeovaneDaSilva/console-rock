# Wrapper around Redis which sets a TTL on values
class GeocoderCacheStore
  TTL = 604_800 # 7 days

  delegate :del, :keys, to: :store

  def [](url)
    store.get(url)
  end

  def []=(url, value)
    store.set(url, value, ex: TTL)
  end

  private

  def store
    @store ||= Redis.new(
      url: ENV.fetch("THREAT_LOOKUP_URL", ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0"))
    )
  end
end

Geocoder.configure(
  ip_lookup: :ipinfo_io,
  api_key:   ENV["IPINFO_API_KEY"],
  cache:     GeocoderCacheStore.new
)
