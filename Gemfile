source "https://rubygems.org"

ruby "2.5.7"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "connection_pool"
gem "rails", "~> 5.2.5"

# Logging
gem "httplog", "~> 1.5"
gem "lograge"
gem "logstash-event", "~> 1.2"
gem "sidekiq-logstash", "~> 2.0"

gem "pg"
gem "puma", "~> 5.3"
gem "dalli"

# Database
gem "activerecord-import", "~> 1.1"
gem "pg_ltree"
gem "pg_search", "~> 2.3"
gem "sidekiq"
gem "sidekiq-cron"
gem "money-rails"
gem "bitmask_attributes"
gem "strong_migrations"
gem "textacular"
gem "pghero"
gem "with_advisory_lock"
gem "makara", "~> 0.5.1"

# Frontend
gem "bootstrap_form", "~> 2.7"
gem "jquery-rails"
gem "sass-rails", "~> 6.0"
gem "slim-rails"
gem "turbolinks", "~> 5"
gem "uglifier", ">= 1.3.0"
gem "aws-sdk"
gem "jbuilder"
gem "jbuilder_cache_multi"
gem "kaminari"
gem "kaminari-bootstrap", "~> 3.0.1"
gem "pagy", "~> 3.13.0"
gem "sprockets-es6"
gem "premailer-rails"
gem "nested_form_fields"
gem "webpacker"
gem "inline_svg"

# Misc
gem "zip-zip"
gem "countries", require: "countries/global"
gem "dry-types", "~> 1.5"
gem "dry-struct", "~> 1.4"
gem "braintree"
gem "flipper", "~> 0.21.0"
gem "flipper-redis", "~> 0.21.0"
gem "flipper-ui", "~> 0.21.0"
gem "ipaddress"
gem "geocoder"
gem "faraday"
gem "faraday_middleware"
gem "faraday_middleware-aws-signers-v4"
gem "sentry-raven"
gem "rack-attack"
gem "barnes"
gem "axlsx"
gem "httpi"
gem "bootsnap"
gem "concurrent-ruby"
gem "traffic_jam", github: "coinbase/traffic_jam"
gem "encryptor"
gem "falconz"
gem "rails_autoscale_agent", github: "adamlogic/rails_autoscale_agent", branch: "master"
gem "rqrcode"
gem "jwt"
gem "json_logic"
gem "activejob-status"

# Performance
gem "scout_apm"

# Authentication & Authorization
gem "devise"
gem "devise_invitable"
gem "pundit"
gem "breezy_pdf_lite"
gem "two_factor_authentication"
gem "rack-cors"

# Auditing
gem "audited"

group :development, :test do
  gem "awesome_print", "~> 1.9"
  gem "active_record_query_trace"
  gem "faker", "~> 2.18"
  gem "rspec-rails"
  gem "pry-byebug"
  gem "pry-doc"
  gem "pry-rails"
  gem "pry-remote"
  gem "pry-rescue"
  gem "parallel_tests"
end

group :development, :test, :staging do
  gem "factory_bot_rails"
  gem "timecop"
  gem "rack-mini-profiler"
  gem "memory-profiler"
  gem "flamegraph"
  gem "stackprof"
end

group :development do
  gem "guard-rspec"
  gem "guard-rubocop"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false

  gem "spring"
  gem "web-console"

  gem "bullet", "~> 6.1"
  gem "terminal-notifier-guard"

  gem "foreman"
end

group :test do
  gem "database_cleaner"
  gem "db-query-matchers"
  gem "capybara"
  gem "selenium-webdriver"
  gem "vcr"
  gem "webmock"
  gem "roo", "2.7.1" # For testing xlsx generation
  gem "rspec_junit_formatter"
end
