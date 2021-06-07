# namespace :sidekiq do
#   task stats: :environment do
#     stats = Sidekiq::Stats.new
# Rails.logger.tagged("Stats") do
#   Rails.logger.info "Sidekiq Stats processed=#{stats.processed} enqueued=#{stats.enqueued} \
#                      retry=#{stats.retry_size} busy=#{stats.workers_size}"
# end
#   end
# end
