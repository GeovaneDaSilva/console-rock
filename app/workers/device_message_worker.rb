# Processes device messages sent over websockets
class DeviceMessageWorker
  include Sidekiq::Worker

  MESSAGE_MAP = {
    log: DeviceMessages::Log,                           connected: DeviceMessages::Connection,
    disconnected: DeviceMessages::Connection,           heartbeat: DeviceMessages::Heartbeat,
    hunt_started: DeviceMessages::HuntStart,            hash_progress: DeviceMessages::HashProgress,
    ip_info: DeviceMessages::IpInfo,                    threat_evaluation: DeviceMessages::ThreatEvaluation,
    ready: DeviceMessages::Ready,                       defender_status: DeviceMessages::DefenderStatus,
    isolate: DeviceMessages::Isolation,                 restore: DeviceMessages::Isolation,
    remediate: DeviceMessages::Remediation,             reporting: DeviceMessages::Reporting
  }.with_indifferent_access

  QUEUE_MAP = {
    threat_evaluation: "threat_evaluation",
    ip_info:           "ip_info",
    connected:         "pushed-tasks",
    disconnected:      "pushed-tasks",
    heartbeat:         "pushed-tasks",
    hunt_started:      "pushed-tasks",
    log:               "log"
  }.with_indifferent_access

  sidekiq_options queue: "default"

  def perform(message)
    klass = MESSAGE_MAP[message["type"]]
    queue = QUEUE_MAP[message["type"]] || "pushed-tasks"
    # TODO: things get defaulted to "pushed-tasks" if not in the QUEUE_MAP?  That's the 2nd-highest priority

    sample_transactions_for_scout_apm

    ServiceRunnerJob.set(queue: queue).perform_later(klass.name, message) if klass
  end

  private

  def apm_sample_rate
    # sample 0.1% of transactions
    0.001
  end

  def sample_transactions_for_scout_apm
    return unless Rails.env.production?

    ScoutApm::Transaction.ignore! if rand > apm_sample_rate
  end
end
