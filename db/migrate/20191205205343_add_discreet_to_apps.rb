class AddDiscreetToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :discreet, :boolean
    change_column_default :apps, :discreet, from: nil, to: false

    reversible do |dir|
      dir.up do
        App.update_all(discreet: false)
        App.where(beta: true).update_all(discreet: true)
      end
    end
  end
end
