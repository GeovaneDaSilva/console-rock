class CreateAvConfigTable < ActiveRecord::Migration[5.2]
  def change
    create_table :antivirus_customer_maps do |t|
      t.integer   :account_id
      t.string    :antivirus_id
      t.integer   :app_id

      t.timestamps
    end
  end
end
