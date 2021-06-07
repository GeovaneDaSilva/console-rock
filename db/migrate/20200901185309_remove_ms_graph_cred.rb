class RemoveMsGraphCred < ActiveRecord::Migration[5.2]
  def change
    drop_table :ms_graph_credentials
  end
end
