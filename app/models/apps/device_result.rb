module Apps
  # :nodoc
  class DeviceResult < Result
    belongs_to :device

    scope :ttp, -> { where(%(details -> 'attributes' ? 'ttp_id')) }

    before_commit :set_confidence!, on: :create
    after_commit :geocode_threat!, on: :create, if: :geocodeable?
    after_commit :send_ml_feedback, if: :incident_changed?
    before_destroy :send_ml_feedback

    def ttp?
      details.ttp_id.present?
    end

    def ttp
      TTP.find(details.ttp_id) if ttp?
    end

    def geocode_threat!
      return unless geocodeable?

      ServiceRunnerJob.set(queue: :utility).perform_later(
        "Threats::Geocode", value, device.customer, self
      )
    end

    def set_confidence!
      return unless Rails.application.config.submit_ml

      ServiceRunnerJob.set(queue: :utility).perform_later("Threats::Ml::Submit", self)
      reload
    end

    def geocodeable?
      value_type.match(/ip/i).present?
    end

    def send_ml_feedback
      return unless Rails.application.config.submit_ml_feedback

      ServiceRunnerJob.set(queue: :utility)
                      .perform_later("Administration::AppResults::SendToMlData", to_json)
    end
  end
end
