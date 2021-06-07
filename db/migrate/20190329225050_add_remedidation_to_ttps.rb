class AddRemedidationToTTPs < ActiveRecord::Migration[5.2]
  def change
    add_column :ttps, :remediation, :text
  end
end
