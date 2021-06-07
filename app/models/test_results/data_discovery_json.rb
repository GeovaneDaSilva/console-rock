module TestResults
  # :nodoc
  class DataDiscoveryJson < BaseJson
    def archive?
      @archive ||= discoveries.collect(&:path).compact.uniq.present?
    end
  end
end
