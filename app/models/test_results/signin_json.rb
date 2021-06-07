module TestResults
  # Represents a test result detail json/hash entry office 365 signin from MS graph
  class SigninJson < BaseJson
    def username
      if user.is_a?(Hash)
        user["principalName"]
      elsif user.is_a?(BaseJson)
        user.userprincipalname
      end
    end

    alias principalname username

    def city_state_country
      [city, state, country].reject(&:blank?).join(", ")
    end

    def city
      if location.is_a?(Hash)
        location["city"]
      elsif location.is_a?(BaseJson)
        location.city
      end
    end

    def state
      if location.is_a?(Hash)
        location["state"]
      elsif location.is_a?(BaseJson)
        location.state
      end
    end

    def country
      if location.is_a?(Hash)
        location["countryOrRegion"]
      elsif location.is_a?(BaseJson)
        location.countryorregion
      end
    end

    def detection_count
      if threat_detail.is_a?(Hash)
        threat_detail.fetch("detections", 0)
      elsif threat_detail.is_a?(BaseJson)
        threat_detail.detections || 0
      else
        0
      end
    end

    def login_attempt
      if user.is_a?(Hash)
        user["loginAttempt"].to_s.capitalize
      elsif user.is_a?(BaseJson)
        user.loginattempt.to_s.capitalize
      end
    end
  end
end
