class AppResultsToSti < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :apps_results, :type, :string
    add_column :apps_results, :customer_id, :integer

    Apps::Result.reset_column_information
    Apps::Result.update_all(type: "Apps::DeviceResult")

    reversible do |dir|
      dir.up do
        Apps::DeviceResult.reset_column_information

        Apps::DeviceResult.find_each do |result|
          result.update_column(
            :customer_id,
            result.device.customer.id
          )
        end
      end
    end

    add_index :apps_results, :customer_id, algorithm: :concurrently, unique: false
  end
end
