Braintree::Configuration.environment = ENV.fetch("BRAINTREE_ENV", "production").to_sym
Braintree::Configuration.merchant_id = ENV["BRAINTREE_MERCHANT_ID"]
Braintree::Configuration.public_key = ENV["BRAINTREE_PUBLIC_KEY"]
Braintree::Configuration.private_key = ENV["BRAINTREE_PRIVATE_KEY"]

Braintree::Configuration.logger = Logger.new("/dev/null") if Rails.env.test?
