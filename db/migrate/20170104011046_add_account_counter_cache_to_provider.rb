class AddAccountCounterCacheToProvider < ActiveRecord::Migration[5.0]
  def change
    add_column :providers, :account_count, :integer, default: 0
  end
end
