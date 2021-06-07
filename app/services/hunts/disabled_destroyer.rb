module Hunts
  # :nodoc
  class DisabledDestroyer
    def call
      Hunt.disabled.where("updated_at < ?", 2.weeks.ago).find_each do |hunt|
        ServiceRunnerJob.set(queue: :utility).perform_later(
          "Hunts::Destroyer", hunt
        )
      end
    end
  end
end
