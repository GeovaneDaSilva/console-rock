class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.integer :provider_id
      t.boolean :can_customize_logo, default: false, null: false

      t.timestamps
    end

    add_index :settings, :provider_id
  end
end
