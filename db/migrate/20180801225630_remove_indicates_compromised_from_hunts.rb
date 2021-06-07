class RemoveIndicatesCompromisedFromHunts < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :hunts, :indicates_compromised, :boolean, default: true, null: false
    end
  end
end
