# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password]

Rails.application.config.filter_parameters += [/api_key/, /secret/, /token/] unless Rails.env.development?
