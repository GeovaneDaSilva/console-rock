# Publish an event to subscribers
class EventPublisher
  EVENT_PRIORITY_MAP = {
    high:   %i[malicious_indicator],
    medium: %i[],
    low:    %i[suspicious_indicator]
  }.freeze

  def initialize(account, device, type, payload = {})
    @account = account
    @device = device
    @type = type.to_sym
    @payload = payload

    @priority = priority || :low
  end

  def call
    subscriptions.find_each do |subscription|
      ServiceRunnerJob.perform_later(
        notifier_klass_for_subscription(subscription),
        subscription,
        @account, @device, @type.to_s, @priority.to_s, @payload
      )
    end
  end

  private

  def subscriptions
    @subscriptions ||= Subscription.with_event_types(@type).where(account: @account.self_and_ancestors)
  end

  def priority
    %i[high medium low].find do |indicator|
      EVENT_PRIORITY_MAP[indicator].include?(@type)
    end
  end

  def notifier_klass_for_subscription(subscription)
    "Notifiers::#{subscription.class.name.split('Subscriptions::').last}"
  end
end
