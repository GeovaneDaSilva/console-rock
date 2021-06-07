class AddTwoFactorsToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :two_factors, :jsonb
  end
end
