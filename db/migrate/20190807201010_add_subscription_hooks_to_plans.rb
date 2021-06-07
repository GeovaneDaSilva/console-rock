class AddSubscriptionHooksToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :subscribed_hooks, :text, array: true
    add_column :plans, :unsubscribed_hooks, :text, array: true

    change_column_default :plans, :subscribed_hooks, from: nil, to: []
    change_column_default :plans, :unsubscribed_hooks, from: nil, to: []
  end
end
