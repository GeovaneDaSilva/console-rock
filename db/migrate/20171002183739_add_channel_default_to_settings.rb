class AddChannelDefaultToSettings < ActiveRecord::Migration[5.1]
  def up
    change_column_default :settings, :channel, 0

    Setting.where(channel: nil).update_all(channel: 0)
  end

  def down
    change_column_default :settings, :channel, nil

    Setting.where(channel: 0).update_all(channel: nil)
  end
end
