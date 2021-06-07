class AddDisableSubSubscriptionsToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :disable_sub_subscriptions, :boolean

    change_column_default :accounts, :disable_sub_subscriptions, from: nil, to: false

    reversible do |dir|
      dir.up do
        Account.reset_column_information

        Account.update_all(disable_sub_subscriptions: false)
      end
    end
  end
end
