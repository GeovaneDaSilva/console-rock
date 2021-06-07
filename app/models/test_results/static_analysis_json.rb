module TestResults
  # Represents a test result detail json/hash entry static analysis
  class StaticAnalysisJson < BaseJson
    ORDER = %i[
      risk_level verdict file_path findings
    ].freeze
  end
end
