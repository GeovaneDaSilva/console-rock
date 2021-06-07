module Notifiers
  # Base class for event notifiers
  class Base
    def initialize(subscription, account, device, type, priority, payload)
      @subscription = subscription
      @account      = account
      @device       = device
      @type         = type.to_sym
      @priority     = priority
      @payload      = payload
    end

    def call
      raise NotImplementedError
    end
  end
end
