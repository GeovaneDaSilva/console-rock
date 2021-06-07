module Hunts::OnDemand
  # :nodoc
  class BaseController < AuthenticatedController
    private

    def queue_hunts_broadcast!
      ServiceRunnerJob.set(queue: "ui").perform_later("Broadcasts::Hunts::Changed", hunt)
    end
  end
end
