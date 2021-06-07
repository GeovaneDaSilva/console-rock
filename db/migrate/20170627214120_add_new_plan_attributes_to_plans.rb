class AddNewPlanAttributesToPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :plans, :max_monitored_devices, :integer
    add_column :plans, :max_audited_devices, :integer
    add_column :plans, :price_per_device_overage_cents, :integer, default: 0
    add_column :plans, :price_per_device_overage_currency, :string, default: "USD"
    add_column :plans, :price_per_audit_overage_cents, :integer, default: 0
    add_column :plans, :price_per_audit_overage_currency, :string, default: "USD"
  end
end
