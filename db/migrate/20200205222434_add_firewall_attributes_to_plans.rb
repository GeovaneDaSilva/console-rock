class AddFirewallAttributesToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :included_firewalls, :integer
    add_column :plans, :price_per_firewall_overage_cents, :integer
    add_column :plans, :price_per_firewall_overage_currency, :string

    change_column_default :plans, :included_firewalls, from: nil, to: 0
    change_column_default :plans, :price_per_firewall_overage_cents, from: nil, to: 0
    change_column_default :plans, :price_per_firewall_overage_currency, from: nil, to: "USD"

    reversible do |dir|
      dir.up do
        Plan.update_all(
          included_firewalls: 0, price_per_firewall_overage_cents: 100,
          price_per_firewall_overage_currency: "USD"
        )
      end
    end
  end
end
