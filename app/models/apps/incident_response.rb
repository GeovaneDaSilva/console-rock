module Apps
  # :nodoc
  class IncidentResponse < ApplicationRecord
    has_many :app_results, class_name: "Apps::DeviceResult", dependent: :nullify
    has_many :devices, through: :app_results

    validates :remediation_body, presence: true

    def featured_attributes=(val)
      super(val.reject(&:blank?))
    end
  end
end
