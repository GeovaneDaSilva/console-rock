class MigrateRelatedLtreeData < ActiveRecord::Migration[5.2]
  def change
    Customer.find_each do |customer|
      customer.devices.update_all(account_path: customer.path)
      Apps::Result.where(customer: customer).update_all(account_path: customer.path)

      HuntResult.joins(:device).where(devices: { customer_id: customer.id })
                               .update_all(account_path: customer.path)
    end
  end
end
