class CreateUserRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :user_roles do |t|
      t.integer :role, null: false, default: 0
      t.references :roleable, polymorphic: true, index: true, null: false
      t.references :user, index: true, null: false

      t.timestamps
    end
  end
end
