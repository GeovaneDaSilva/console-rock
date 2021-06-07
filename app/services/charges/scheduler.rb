module Charges
  # Queues job tos charge applicable objects
  class Scheduler
    def call
      # Rails.logger.info("Scheduling charges for due accounts")
      Account.chargeable.find_each do |account|
        ServiceRunnerJob.set(queue: :billing).perform_later("Charges::Charger", account, account.plan)
      end

      true
    end
  end
end
