class AddAuthorToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :author, :integer

    change_column_default :apps, :author, from: nil, to: 0

    reversible do |dir|
      dir.up do
        App.reset_column_information
        App.update_all(author: 0)
      end
    end
  end
end
