class AddChannelToSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :settings, :channel, :integer
  end
end
