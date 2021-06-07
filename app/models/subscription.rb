# Represents an event subscription
class Subscription < ApplicationRecord
  include AttrJsonable
  include Encryptable

  ENABLED_EVENT_TYPES = [].freeze

  belongs_to :account

  bitmask :event_types, as: %i[
    malicious_indicator suspicious_indicator managed_service_event_summary device_inactive
  ], zero_value: :none

  # Autotask attributes
  attr_json_accessor :configuration, :customer_identifier, :device_identifier, :email_address,
                     :send_blank_email, :disabled_apps, :unmanaged_notification_types, :phone_number

  after_initialize do |sub|
    sub.event_types = sub.class::ENABLED_EVENT_TYPES unless sub.persisted? || sub.event_types.length.positive?
    sub.disabled_apps ||= App.suspicious_event_config.pluck(:id)
  end

  scope :email, -> { where(type: "Subscriptions::Email") }

  def disabled_apps=(values)
    self.configuration ||= {}

    configuration.merge!(
      "disabled_apps" => (values == ["none"] ? [] : values.collect(&:to_i))
    )
  end
end
