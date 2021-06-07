module Opswat
  # Represents a Opswatq API response
  class Base
    attr_reader :response

    def initialize(response)
      @response = response.to_h
    end

    def unknown?
      response.empty?
    end

    def suspicious?
      !compromise? && (30..65).cover?(confidence)
    end

    def compromise?
      confidence >= 65
    end

    def clear?
      !unknown? && !suspicious? && !compromise?
    end

    def confidence
      if total.zero?
        0.0
      else
        positives / total * 100.0
      end
    end

    def threat_name
      return "Unknown" if unknown? || clear?

      threat_name = scan_details.collect do |_k, details|
        details.dig("threat_found") if details.dig("scan_result_i") == 1
      end.first

      threat_name || "Unknown"
    end

    private

    def positives
      response.dig("scan_results", "total_detected_avs") || 0
    end

    def total
      response.dig("scan_results", "total_avs") || 0
    end

    def scan_details
      response.dig("scan_results", "scan_details").to_h
    end
  end
end
