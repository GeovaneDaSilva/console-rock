class AddAllowMovingInfoToApiKeys < ActiveRecord::Migration[5.2]
  def change
    add_column :api_keys, :allow_moving_info, :boolean, default: false
  end
end
