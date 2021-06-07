# load this to add .to_json method to exceptions
require "json/add/exception"

# HTTP
# ==============================================================================
# NOTE: over time, as our error tracking improves, this gem can be removed and instead
# replaced with errors sending the appropriate logs for debugging in production (& development :)
HttpLog.configure do |config|
  config.enabled = true
  config.logger = Rails.configuration.logger
  config.severity = Logger::Severity::INFO
  config.json_log = true
  config.compact_log = true
  # NOTE: this may not filter URL :get params properly, not sure yet.
  config.filter_parameters = Rails.configuration.filter_parameters
end

# Prevent HTTPI from sending logs.
HTTPI.log = false

# Rails Logging
# ==============================================================================
# rubocop:disable Metrics/BlockLength
Rails.application.configure do
  # Lograge
  # ----------------------------------------------------------------------------
  # Enabling lograge is taken-care-of in each of the environment-specific
  # configuation files. Search for `config.lograge.enabled`
  if config.lograge.enabled
    config.lograge.logger = config.logger
    config.lograge.formatter = Lograge::Formatters::Logstash.new
    config.lograge.custom_options = lambda { |event|
      Logging::LogrageCustomOptions.call(event).attributes
    }

    # base controllers
    config.lograge.base_controller_class = ["ActionController::Base"]

    # ignore highly-active endpoints in order to save on logging costs.
    # NOTE: if we start to have errors in any of these areas then we should temporarily
    # remove the troublesome endpoint's entry here.
    ignore_actions_unless_error = [
      # API endpoints
      "Api::V1::Customers::DevicesController#update",
      "Api::V1::Customers::SupportsController#index",
      "Api::V1::Customers::SupportsController#show",
      "Api::V1::Devices::Apps::ResultsController#create",
      # ActionCable endpoints
      "ApplicationCable::Connection#connect",
      "AccountTemplateChannel#subscribe",
      "AccountTemplateChannel#subscribed",
      "AccountTemplateChannel#unsubscribe",
      "AppsChannel#refresh",
      "AppsChannel#subscribe",
      "AppsChannel#subscribed",
      "AppsChannel#unsubscribe",
      "AppsChannel#unsubscribed",
      "DeviceAppsChannel#refresh",
      "DeviceAppsChannel#subscribed",
      "DeviceAppsChannel#unsubscribed",
      "DeviceStatusChannel#refresh",
      "DeviceStatusChannel#subscribed",
      "DeviceStatusChannel#unsubscribed"
    ]

    unless Rails.env.development?
      config.lograge.ignore_custom = Logging::LogrageIgnoreUnlessError.new(ignore_actions_unless_error)
    end
  end
end
# rubocop:enable Metrics/BlockLength

# disable view logs outside of development
unless Rails.env.development?
  %w[render_template render_partial render_collection].each do |event|
    ActiveSupport::Notifications.unsubscribe("#{event}.action_view")
  end
end

# Jobs
# ==============================================================================
# Disable active-job logging in favour of sidekiq logging. Active-job logging is too verbose with
# not as much information in the payload as you'd like. I've opted for using sidekiq logs here
# because there are more details in the event, and it's possible to extract the missing
# active-job attributes from the sidekiq payload.
ActiveJob::Base.logger = ActiveSupport::Logger.new(IO::NULL)

Sidekiq::Logstash.setup

Sidekiq::Logstash.configure do |config|
  config.job_start_log = false
  config.filter_args += Rails.configuration.filter_parameters
  config.custom_options = lambda { |payload|
    Logging::SidekiqCustomOptions.call(payload)
  }
end

Sidekiq.configure_server do |server|
  server.logger.formatter = Logging::SidekiqLoggerFormatter.new
  # TODO: extend server logger to enable this functionality. Should only ignore
  # info events, not error events
  # server.logger.ignore_jobs = [...]
end

Sidekiq.configure_client do |client|
  logger = ActiveSupport::Logger.new($stdout)
  client.logger.formatter = Logging::RailsLoggerFormatter.new
  client.logger = ActiveSupport::TaggedLogging.new(logger)
end

# Tools
# ==============================================================================
# for development use only. This gem does not load in production.
ActiveRecordQueryTrace.enabled = ENV["ACTIVE_RECORD_QUERY_TRACE_ENABLED"].present? if Rails.env.development?
