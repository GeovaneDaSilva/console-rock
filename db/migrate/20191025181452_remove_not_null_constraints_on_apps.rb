class RemoveNotNullConstraintsOnApps < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        dir.up do
          Apps::DeviceResult.reset_column_information

          Apps::DeviceResult.where(customer_id: nil).find_each do |result|
            result.update(customer_id: result.device.customer_id)
          end

          change_column_null :apps_results, :customer_id, false
          change_column_null :apps_results, :device_id, true
          change_column_null :apps, :upload_id, true
        end

        dir.down do
          change_column_null :apps_results, :customer_id, true
          change_column_null :apps_results, :device_id, false
          change_column_null :apps, :upload_id, false
        end
      end
    end
  end
end
