Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  asset_host = "http://#{ENV.fetch('HOST', 'console.test')}:#{5550 + ENV.fetch('TEST_ENV_NUMBER', '1').to_i}"
  config.action_controller.asset_host = asset_host
  config.action_mailer.default_url_options = { host: asset_host }
  config.action_mailer.asset_host = nil
  # Don't create search indexes
  config.search_index_strategy = false

  config.active_job.queue_adapter = :inline

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  redis_db = ENV.fetch("TEST_ENV_NUMBER", "1").to_i + 1 # +1 to avoid local dev db

  config.cache_store = :redis_cache_store, {
    url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/#{redis_db}")
  }

  config.redis_record_store = ConnectionPool::Wrapper.new(
    size: Integer(ENV.fetch("REDIS_RECORD_POOL_SIZE", 1))
  ) do
    Redis.new(
      url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/#{redis_db}")
    )
  end

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=3600"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.index_models = false
  config.lograge.enabled = false

  config.after_initialize do
    PIPELINE_CONFIGS[:archive][:destroy_limit] = 2
  end

  # Minimum amount of logging in test
  config.log_level = :fatal
end
