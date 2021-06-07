module Providers
  # move source account to be a sub account of target account
  class Move
    def initialize(source_account_id, target_account_id)
      @source = Account.find_by(id: source_account_id)
      @target = Account.find_by(id: target_account_id)
    end

    def call
      return if @source.nil? || @target.nil?

      DatabaseTimeout.timeout(0) do
        ActiveRecord::Base.transaction do
          move_to_target([@source], @target) do |old_path, new_path|
            update_ltree_references(old_path, new_path)
          end
        end

        return unless @source.reload.root == @target

        source_plan_update
        @source.move_codes.destroy_all
        ApiKey.where(account: @source, allow_moving_info: true).destroy_all
      end
      # ServiceRunnerJob.perform_later("Accounts::StandardizeSubAccountPaidThru", @source, @target)
    end

    private

    def move_to_target(sources, target, counter = 1, &block)
      # never recurse without protection
      return if counter > 4

      sources.each do |source|
        old_path = source.path
        new_path = [target.path, source.id.to_s].join(".")
        descendants = source.all_descendants.to_a
        source.path = new_path
        source.plan_id = nil
        source.save
        yield(old_path, new_path)

        move_to_target(descendants, source, counter + 1, &block) unless descendants&.empty?
      end
    end

    def update_ltree_references(old_path, new_path)
      [Device, RocketcyberIntegrationMap, MappingConfig, Apps::CounterCache, BillableInstance,
       Apps::Incident, Apps::Result, FirewallCounter, RemediationPlan, HuntResult,
       LogicRule].each do |klass|
        klass.where(account_path: old_path).update_all(account_path: new_path)
      end
    end

    def source_plan_update
      if @target.plan.plan_type == "pax8" && recent_charge.blank?
        new_plan = Plan.find_by(name: "Transition to Pax8")
        @source.update(plan_id: new_plan&.id)
      else
        @source.update(plan_id: @target.plan_id)
      end
    end

    def recent_charge
      Charge.where(account_id: account_ids).where("end_date > ?", 1.day.ago)
    end

    def account_ids
      @source.self_and_all_descendants.pluck(:id)
    end
  end
end
