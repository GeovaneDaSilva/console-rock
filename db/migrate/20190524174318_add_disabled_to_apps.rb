class AddDisabledToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :disabled, :boolean
    change_column_default :apps, :disabled, from: nil, to: false

    reversible do |dir|
      dir.up do
        App.reset_column_information

        App.update_all(disabled: false)
      end
    end
  end
end
