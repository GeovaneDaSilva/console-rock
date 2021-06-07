class RemoveUnusedDbColumns < ActiveRecord::Migration[5.1]
  def change
    remove_column :plans, :price_per_audit_overage_currency, :string, default: "USD"
    remove_column :plans, :price_per_audit_overage_cents, :integer, default: 0
    remove_column :plans, :max_audited_devices, :integer, default: 0
  end
end
