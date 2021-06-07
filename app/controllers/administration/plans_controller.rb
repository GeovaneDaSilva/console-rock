module Administration
  # Admin views for plans
  class PlansController < Administration::BaseController
    include Pagy::Backend

    before_action :authorize!
    before_action :plan, only: %i[edit update destroy]

    def index
      plans = Plan.order("price_per_frequency_cents ASC, price_per_device_overage_cents ASC")
      @pagination, @plans = pagy plans
    end

    def new
      @plan = Plan.new

      build_plan_apps
    end

    def create
      @plan = Plan.new(plan_params)

      if @plan.save
        redirect_to administration_plans_path, notice: "Created plan"
      else
        flash.now[:error] = "Unable to save plan"
        render :new
      end
    end

    def edit
      build_plan_apps
    end

    def update
      authorize plan

      if plan.update(plan_params)
        redirect_to administration_plans_path, notice: "Plan updated"
      else
        flash.now[:error] = "Unable to update plan"
        render :edit
      end
    end

    def destroy
      authorize plan

      if plan.destroy
        redirect_to administration_plans_path, notice: "Plan removed"
      else
        flash.now[:error] = "Unable to destroy plan"
        redirect_to administration_plans_path
      end
    end

    private

    def authorize!
      authorize :administration, :manage_plans?
    end

    def plan
      @plan ||= Plan.find(params[:id])
    end

    def build_plan_apps
      App.ga.each do |app|
        @plan.plan_apps.build(app: app) unless @plan.apps.include?(app)
      end
    end

    def plan_params
      params.require(:plan).permit(
        :name, :description, :frequency, :price_per_frequency, :published, :included_devices,
        :threat_hunting, :threat_intel_feeds, :managed, :price_per_device_overage,
        :included_office_365_mailboxes, :price_per_office_365_mailbox_overage,
        :included_firewalls, :price_per_firewall_overage, :trial, :hide_billing, :hide_unassigned_apps,
        subscribed_hooks: [], unsubscribed_hooks: [], on_demand_analysis_types: [],
        on_demand_hunt_types: [], plan_apps_attributes: %i[_destroy app_id id]
      )
    end
  end
end
