module Apps
  # Unified definition of possible app result verdicts
  # Requires verdict column of type integer
  module Verdictable
    extend ActiveSupport::Concern

    included do
      enum verdict: {
        malicious:     1,
        suspicious:    2,
        informational: 3
      }
    end
  end
end
