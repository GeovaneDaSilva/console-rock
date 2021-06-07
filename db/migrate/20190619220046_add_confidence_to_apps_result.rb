class AddConfidenceToAppsResult < ActiveRecord::Migration[5.2]
  def change
    add_column :apps_results, :confidence, :string
  end
end
