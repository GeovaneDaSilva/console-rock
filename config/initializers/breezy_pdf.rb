BreezyPDFLite.setup do |config|
  config.secret_api_key = ENV["BREEZYPDF_SECRET_API_KEY"]
  config.base_url = ENV.fetch("BREEZYPDF_BASE_URL", "http://localhost:5001")
end
