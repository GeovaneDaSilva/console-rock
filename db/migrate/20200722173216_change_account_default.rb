class ChangeAccountDefault < ActiveRecord::Migration[5.2]
  def up
    change_column_default :accounts, :disable_sub_subscriptions, true
  end

  def down
    change_column_default :accounts, :disable_sub_subscriptions, false
  end
end
