module Devices
  # Redis backed defender status
  class DefenderStatus < RedisRecord
    def quick_scan_in_progress?
      scan_in_progress? && current_scan_type == "quick"
    end

    def full_scan_in_progress?
      scan_in_progress? && current_scan_type == "full"
    end

    def scan_in_progress?
      scan_status.fetch("start_time", 0) > payload.dig("last_#{current_scan_type}_scan", "end_time").to_i
    end

    def current_scan_type
      scan_status.fetch("scan_type", "none").downcase
    end

    def scan_status
      payload.fetch("scan_status", {})
    end

    def payload
      @attrs["payload"].to_h
    end

    def method_missing(method, *_args, &_blk)
      if payload.keys.include?(method.to_s)
        payload[method.to_s]
      else
        super
      end
    end

    def respond_to_missing?(method, *)
      payload.keys.include?(method.to_s) || super
    end
  end
end
