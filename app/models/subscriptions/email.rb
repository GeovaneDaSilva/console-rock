module Subscriptions
  # Email subscription
  class Email < Subscription
    ENABLED_EVENT_TYPES = %i[malicious_indicator suspicious_indicator].freeze

    # validates :email_address, presence: true

    def send_blank_email
      [true, "true"].include?(super)
    end
  end
end
