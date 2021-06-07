class CreateAnalysisBases < ActiveRecord::Migration[5.2]
  def change
    create_table :analyses do |t|
      t.jsonb :resource
      t.string :type, index: true
      t.integer :status, default: 0, null: false
      t.references :user
      t.references :account

      t.timestamps
    end
  end
end
