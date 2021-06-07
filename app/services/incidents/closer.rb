# :nodoc
module Incidents
  # :nodoc
  class Closer
    def call(time = 4.days.ago)
      Apps::Incident.where("created_at > ?", time).where(state: %i[published draft]).find_each do |incident|
        next unless incident.results.size.zero?

        ::Incidents::Integrations.close_ticket(incident, incident.account)
      end

      ServiceRunnerJob.set(wait: 10.minutes).perform_later("Incidents::Cleaner")
    end
  end
end
