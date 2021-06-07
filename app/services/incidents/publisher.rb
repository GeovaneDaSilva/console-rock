# :nodoc
module Incidents
  # :nodoc
  class Publisher
    def call
      Apps::Incident.where(state: :draft, creator_id: autobot).find_each do |incident|
        next if incident.results.size.zero?

        ::Incidents::Integrations.create_ticket(incident) if incident.published!
      end
    end

    def autobot
      Rails.cache.fetch("incident-auto-user") do
        User.find_by(email: "dolivaw@rocketcyber.com")&.id || User.first.id
      end
    end
  end
end
