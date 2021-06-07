module Plans
  # Execute plan hooks on subscription change
  class SubscriptionChange
    HOOK_MAP = {
      "enable_managed_service_event_summary"  => Plans::Hooks::EnableManagedServiceEventSummary,
      "disable_managed_service_event_summary" => Plans::Hooks::DisableManagedServiceEventSummary,
      "disable_office365_apps"                => Plans::Hooks::DisableOffice365Apps
    }.freeze

    # old_plan may be nil!
    def initialize(account, old_plan)
      @account = account
      @old_plan = old_plan
    end

    def call
      run_unsubscribed_hooks!
      run_subscribed_hooks!
    end

    private

    def run_unsubscribed_hooks!
      return if @old_plan.nil?

      @old_plan.unsubscribed_hooks.each do |hook|
        run_hook(hook)
      end
    end

    def run_subscribed_hooks!
      @account.plan.subscribed_hooks.each do |hook|
        run_hook(hook)
      end
    end

    def run_hook(hook)
      HOOK_MAP[hook].new(@account).call if HOOK_MAP[hook]
    end
  end
end
