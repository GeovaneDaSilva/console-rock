class AddGraphCredToResults < ActiveRecord::Migration[5.2]
  def change
    add_column :apps_results, :ms_graph_credential_id, :integer
  end
end
