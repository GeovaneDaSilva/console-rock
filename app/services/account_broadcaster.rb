# Broadcast updates for applicable account tree
class AccountBroadcaster
  def initialize(account, source = "hunt")
    @account = account
    @source  = source.to_sym
  end

  def call
    @account.self_and_ancestors.each do |account|
      broadcasts(account)
    end

    true
  end

  private

  def broadcasts(account)
    case @source
    when :device
      broadcast_device_connectivity(account)
    end
  end

  def broadcast_device_connectivity(account)
    runner.perform_later("Broadcasts::Accounts::Template", account, "devices_online")
    runner.perform_later("Broadcasts::Accounts::Template", account, "devices_offline")
  end

  def runner
    ServiceRunnerJob.set(queue: "ui")
  end
end
