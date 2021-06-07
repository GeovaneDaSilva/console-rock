require "flipper"
require "flipper/adapters/redis"
require "flipper-ui"

Flipper.configure do |config|
  config.default do
    client = Rails.configuration.redis
    adapter = Flipper::Adapters::Redis.new(client)
    Flipper.new(adapter)
  end
end

Flipper::UI.configure do |config|
  config.fun = false

  if ENV.fetch("RAILS_ENV", "development") == "production"
    config.banner_text = "Production Environment"
    config.banner_class = "danger"
  end
end

# Groups
# ---------------------------------------------------
Flipper.register(:users_internal) do |actor|
  # returns true for users who are admins
  # relevant for users only
  actor.respond_to?(:admin?) && actor.admin?
end

# Add features here
# ---------------------------------------------------
Flipper.add("integrations/psa-mapping/advanced")
Flipper.add("reporting/cyber-monitoring")
Flipper.add("reporting/executive-summary")
Flipper.add("reporting/executive-summary/pdf-generation")
