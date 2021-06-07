module TestResults
  # Represents a test result detail json/hash of a defender detections
  class DefenderDetectionJson < BaseJson
    IGNORED_ATTRS = %i[
      state_id threat_id severity_id detection_id threat_type_id quarantine_guid threat_category_id
      detection_origin_id detection_source_id execution_status_id threat_detection_id pre_execution_status_id
      post_execution_status_id
    ].freeze
  end
end
