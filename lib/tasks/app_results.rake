require "seeds/app_results"

namespace :app_results do
  desc "Seeds app results from staging environment"
  task seed: :environment do
    Seeds::AppResults.new.call
  end
end
