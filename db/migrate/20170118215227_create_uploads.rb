class CreateUploads < ActiveRecord::Migration[5.0]
  def change
    enable_extension "uuid-ossp"

    create_table :uploads, id: :uuid do |t|
      t.integer :status
      t.string :sourceable_type
      t.integer :sourceable_id
      t.string :filename
      t.integer :size

      t.timestamps
    end

    add_index :uploads, [:sourceable_type, :sourceable_id]
  end
end
