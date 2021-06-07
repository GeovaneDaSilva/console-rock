module R
  # Account threat map
  class ThreatMapsController < BaseController
    alias account current_account

    layout "reports"
    helper_method :threats, :egress_ips

    def show
      authorize current_account
      @title = "Threat Map"
    end

    private

    def threats
      @threats ||= GeocodedThreat.where(account: current_account.self_and_all_descendants)
                                 .includes(:threatable)
                                 .order("geocoded_threats.detection_date DESC")
                                 .limit(10)
    end

    def egress_ips
      @egress_ips ||= EgressIp.geocoded
                              .where(customer: current_account.self_and_all_descendants)
                              .load
    end
  end
end
