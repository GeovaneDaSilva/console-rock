class AddFileHashRefreshIntervalToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :file_hash_refresh_interval, :integer
    change_column_default :settings, :file_hash_refresh_interval, from: nil, to: 604_800

    reversible do |dir|
      dir.up do
        Setting.reset_column_information

        Setting.where(file_hash_refresh_interval: nil).update_all(file_hash_refresh_interval: 604_800)
      end
    end
  end
end
