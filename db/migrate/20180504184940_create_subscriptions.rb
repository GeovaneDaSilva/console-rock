class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :account, foreign_key: true
      t.integer :event_types
      t.jsonb :configuration
      t.string :type

      t.timestamps
    end
  end
end
