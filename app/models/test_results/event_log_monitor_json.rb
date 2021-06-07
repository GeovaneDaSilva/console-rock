module TestResults
  # Represents a test result detail json/hash entry File
  class EventLogMonitorJson < BaseJson
    IGNORED_ATTRS = %i[source_name].freeze

    ORDER = %i[
      log_name computer_name event_id event_type time_generated time_written
      record_number event_category message
    ].freeze
  end
end
