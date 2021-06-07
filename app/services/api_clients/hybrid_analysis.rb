module ApiClients
  # :nodoc
  class HybridAnalysis
    def call
      Falconz.client.new(key: ENV["HYBRID_ANALYSIS_API_KEY"])
    end
  end
end
