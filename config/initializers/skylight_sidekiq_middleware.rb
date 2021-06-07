# module Skylight
#   module Core
#     module Sidekiq
#       # Override the Skylight middleware to provide Service class names
#       # When being invoked by the ServiceRunnerJob
#       class ServerMiddleware
#         include Util::Logging
#
#         def initialize(instrumentable)
#           @instrumentable = instrumentable
#         end
#
#         def call(_worker, job, queue)
#           t { "Sidekiq middleware beginning trace" }
#
#           title = if [job["wrapped"], job["class"]].include?("ServiceRunnerJob")
#             begin
#               "ServiceRunnerJob - #{job["args"].first["arguments"].first}"
#             rescue
#               job["wrapped"] || job["class"]
#             end
#           else
#             job["wrapped"] || job["class"]
#           end
#
#           @instrumentable.trace(title, "app.sidekiq.worker", title, segment: queue, component: :worker) do |trace|
#             begin
#               yield
#             rescue Exception # includes Sidekiq::Shutdown
#               trace.segment = "error" if trace
#               raise
#             end
#           end
#         end
#       end
#     end
#   end
# end
