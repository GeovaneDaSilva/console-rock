# A reference/lookup table for Office365Results of type secure_score
# This gives max possible score, potential user impact, etc.
class RefSecureScore < ApplicationRecord
  has_many :app_results, -> { where(value_type: ["", "SecureScoreControlScore"]) },
           class_name: "Apps::Result", foreign_key: :value, dependent: :destroy
end
