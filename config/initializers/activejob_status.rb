# By default
ActiveJob::Status.store = ActiveSupport::Cache::RedisCacheStore.new(
  namespace: "console",
  url:       ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0")
)
