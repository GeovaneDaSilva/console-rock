# :nodoc
module Incidents
  # :nodoc
  class Cleaner
    def call(time = 4.days.ago)
      Apps::Incident.where("created_at > ?", time).find_each do |incident|
        next unless incident.results.size.zero?

        incident.destroy
      end
    end
  end
end
