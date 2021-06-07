module Apps
  # :nodoc
  class Office365Result < CloudResult
    belongs_to :ref_secure_scores, class_name: "RefSecureScore", foreign_key: "value",
      inverse_of: :app_results
  end
end
