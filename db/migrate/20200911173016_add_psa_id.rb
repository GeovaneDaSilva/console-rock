class AddPsaId < ActiveRecord::Migration[5.2]
  def change
    add_column :apps_incidents, :psa_id, :string
  end
end
