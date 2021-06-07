require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require "./lib/compressed_requests"
require "./lib/tidy_bits"
require "./lib/ext/string"

require_relative "../app/lib/logging"
require_relative "../app/lib/logging/rails_logger_formatter"

module Console
  class Application < Rails::Application
    config.generators do |generators|
      generators.view_specs false
    end

    # config.skylight.probes << "active_job"

    config.search_index_strategy = :async

    config.action_cable.mount_path = "/cable"
    config.action_cable.allowed_request_origins = [%r{#{ENV.fetch('HOSTS', ENV['HOST'])}}]

    config.time_zone = "UTC"

    # Respond with GZIP'd data
    config.middleware.insert_after Rack::Sendfile, Rack::Deflater
    config.middleware.insert_after Rack::Deflater, CompressedRequests
    config.middleware.insert_before CompressedRequests, BreezyPDFLite::Middleware
    config.middleware.insert_after CompressedRequests, TidyBits
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"
        resource "/api/integrations/v1/*",
                 headers: :any,
                 expose:  %w[access-control-allow-origin access-control-allow-methods],
                 methods: %i[get post patch put options]
      end
    end

    asset_host = ENV.fetch("HOST", "console.test")
    config.action_controller.asset_host = "https://#{asset_host}"
    config.action_mailer.asset_host = "https://#{asset_host}"

    config.active_record.verbose_query_logs = true

    config.action_mailer.default_url_options = { host: ENV.fetch("HOST", "console.test"), port: 443 }

    config.index_models = true

    config.virus_total_api_limit = ENV.fetch("VIRUS_TOTAL_API_LIMIT", "10").to_i
    config.virus_total_api_limit_duration = ENV.fetch("VIRUS_TOTAL_API_LIMIT_DURATION", "3600").to_i

    config.hybrid_analysis_api_limit = ENV.fetch("HYBRID_ANALYSIS_API_LIMIT", "3").to_i
    config.hybrid_analysis_api_limit_duration = ENV.fetch("HYBRID_ANALYSIS_API_LIMIT_DURATION", "60").to_i

    config.opswat_api_limit = ENV.fetch("OPSWAT_API_LIMIT", "100").to_i
    config.opswat_api_limit_duration = ENV.fetch("OPSWAT_API_LIMIT_DURATION", "60").to_i

    config.submit_ml = ENV["SUBMIT_ML"].present?
    config.submit_ml_feedback = ENV["SUBMIT_ML_FEEDBACK"].present?

    config.redis = ConnectionPool::Wrapper.new(
      size: Integer(ENV.fetch("REDIS_RECORD_POOL_SIZE", 1))
    ) do
      Redis.new(url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0"))
    end

    # Should be configured with LRU redis.io/topics/lru-cache
    config.redis_record_store = ConnectionPool::Wrapper.new(
      size: Integer(ENV.fetch("REDIS_RECORD_POOL_SIZE", 1))
    ) do
      Redis.new(url: ENV.fetch("REDIS_RECORD_URL", ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0")))
    end

    config.ml_redis_store = ConnectionPool::Wrapper.new(
      size: Integer(ENV.fetch("ML_REDIS_POOL_SIZE", 1))
    ) do
      Redis.new(url: ENV.fetch("ML_REDIS_URL", ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0")))
    end

    config.pipeline_analysis_store = ConnectionPool::Wrapper.new(
      size: Integer(ENV.fetch("PIPELINE_ANALYSIS_REDIS_POOL_SIZE", 1))
    ) do
      Redis.new(url: ENV.fetch("PIPELINE_ANALYSIS_REDIS_URL", "redis://127.0.0.1:6379/0"))
    end

    config.threat_lookup_store = ActiveSupport::Cache::RedisCacheStore.new(
      namespace: "console",
      url:       ENV.fetch("THREAT_LOOKUP_URL", ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0"))
    )

    config.old_threat_lookup_store = ActiveSupport::Cache::RedisCacheStore.new(
      namespace: "console",
      url:       ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0")
    )

    config.i18n.fallbacks = [:en]
    config.i18n.default_locale = :en

    # Logging
    # ---------------------------------------
    config.log_tags = %i[request_id]

    # log level
    config.log_level = ENV.fetch("LOG_LEVEL", "info").downcase.to_sym

    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = Logging::RailsLoggerFormatter.new
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end
end
