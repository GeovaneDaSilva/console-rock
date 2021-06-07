module TestResults
  # Represents a test result detail json/hash entry Process
  class AdvancedBreachDetectionJson < ProcessJson
    IGNORED_ATTRS = %i[pe].freeze

    def process_tree?
      process && process.parent_process?
    end
  end
end
