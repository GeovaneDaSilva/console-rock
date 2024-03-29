Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = true

  # Livereload
  config.action_cable.disable_request_forgery_protection = true

  # Settings specified here will take precedence over those in config/application.rb.

  config.active_job.queue_adapter = :sidekiq

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Don't whine about webconsoles from unknown networks
  config.web_console.whiny_requests = false

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join("tmp", "caching-dev.txt").exist?
    config.action_controller.perform_caching = true

    config.cache_store = :redis_cache_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=172800"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :file_store, "/tmp/cache"
  end

  # Care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # SMTP server settings
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    domain:  ENV.fetch("HOST", "console.test"),
    address: "localhost",
    port:    "1025"
  }

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # config.after_initialize do
  #   Bullet.enable = true
  #   Bullet.alert = false
  #   Bullet.bullet_logger = true
  #   Bullet.console = true
  #   Bullet.add_footer = true
  # end

  config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins  ENV.fetch("HOST")
      resource "/assets/*", methods: [:get]
    end
  end

  # Logging
  config.lograge.enabled = true
  config.log_level = :debug
end
