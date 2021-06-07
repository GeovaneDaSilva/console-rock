require "seeds/apps"

namespace :apps do
  desc "Seeds apps from staging environment"
  task seed: :environment do
    Seeds::Apps.new.call
  end
end
