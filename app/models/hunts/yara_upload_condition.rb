module Hunts
  # Condition For a Yara upload
  class YaraUploadCondition < Condition
    validates :condition, presence: true
    validates :operator, inclusion: { in: %w[is_equal_to] }
    validate :upload?

    def upload
      Upload.where(id: condition).first
    end

    private

    def upload?
      errors.add(:condition, "YARA Script required") unless upload
    end
  end
end
