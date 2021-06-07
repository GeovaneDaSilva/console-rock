class CreateDevicesAgentLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :devices_agent_logs do |t|
      t.string :device_id, index: true
      t.string :upload_id, index: true

      t.timestamps
    end
  end
end
