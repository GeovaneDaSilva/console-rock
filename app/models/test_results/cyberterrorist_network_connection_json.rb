module TestResults
  # :nodoc
  class CyberterroristNetworkConnectionJson < BaseJson
    def detection_count
      reputation.to_h.fetch("detections", 0)
    end
  end
end
