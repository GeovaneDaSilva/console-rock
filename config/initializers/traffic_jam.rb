TrafficJam.configure do |config|
  config.redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/"))
  config.key_prefix = "traffic_jam-#{Rails.env}#{ENV['TEST_ENV_NUMBER']}"
end
