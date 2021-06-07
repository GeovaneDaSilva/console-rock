class AddIndicatesCompromisedToHunts < ActiveRecord::Migration[5.1]
  def change
    add_column :hunts, :indicates_compromised, :boolean, default: true, null: false
  end
end
