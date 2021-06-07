module Apps
  # :nodoc
  class IronscalesResult < Apps::CloudResult
    enum classification: {
      report:            1,
      false_positive:    2,
      approved_manually: 3,
      above_threshold:   4,
      federated_attack:  5,
      malicious_content: 6,
      marked_as_spam:    7,
      federated_report:  8,
      ddos_escalation:   9,
      auto_approved:     11,
      link_replacement:  12
    }
  end
end
