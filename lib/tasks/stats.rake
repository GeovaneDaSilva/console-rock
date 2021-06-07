task stats: "console:stats"

namespace :console do
  task stats: :environment do
    require "rails/code_statistics"
    ::STATS_DIRECTORIES.insert(5, %w[Services app/services])
    ::STATS_DIRECTORIES.insert(14, %w[Service\ specs spec/services])
    CodeStatistics::TEST_TYPES << "Services specs"
  end
end
