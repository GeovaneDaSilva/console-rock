module Hunts
  # Condition for event log with Type
  class EventLogTypeCondition < Condition
    validates :condition, presence: true
    validates :operator, inclusion: { in: %w[is_equal_to] }

    enum condition: {
      "Success":       "EVENTLOG_SUCCESS",
      "Error":         "EVENTLOG_ERROR_TYPE",
      "Warning":       "EVENTLOG_WARNING_TYPE",
      "Information":   "EVENTLOG_INFORMATION_TYPE",
      "Audit Success": "EVENTLOG_AUDIT_SUCCESS",
      "Audit Failure": "EVENTLOG_AUDIT_FAILURE"
    }
  end
end
