# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w[
  body.js
  threat-map.js threat-map-includes.js
  dashboard.css
  reports.css reports.js reports_pdf.css toc-styles.xls
  timezone-detection.js email.css
]

Rails.application.config.assets.register_mime_type "text/xls", extensions: %w[.xls]
