class RemoveMsGraphReferences < ActiveRecord::Migration[5.2]
  def up
     safety_assured do
       remove_column :apps_results, :ms_graph_credential_id
       remove_column :accounts, :ms_graph_credential_id
     end
   end
   def down
     add_column :apps_results, :ms_graph_credential_id, :integer
     add_column :accounts, :ms_graph_credential_id, :integer
   end
end
