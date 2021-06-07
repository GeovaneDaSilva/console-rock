# Be sure to restart your server when you modify this file.

ApplicationController.renderer.defaults.merge!(
  http_host: ENV.fetch("HOST", "console.test"),
  https:     Rails.application.config.force_ssl
)
