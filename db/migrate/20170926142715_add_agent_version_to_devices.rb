class AddAgentVersionToDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :agent_version, :string, default: nil
  end
end
