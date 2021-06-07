module Analysis
  # Notify on the analysis
  class Notifier
    def initialize(analysis, count)
      @analysis, @count = analysis, count
    end

    def call
      ServiceRunnerJob.set(wait: wait.seconds)
                      .perform_later("Broadcasts::Analysis", @analysis)

      AnalysisMailer.complete(@analysis).deliver_later if !first? && @analysis.analyzed?
      true
    end

    def wait
      first? ? SecureRandom.rand(2..10) : 0
    end

    def first?
      @count == 1
    end
  end
end
