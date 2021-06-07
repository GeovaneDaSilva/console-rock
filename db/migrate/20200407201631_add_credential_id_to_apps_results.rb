class AddCredentialIdToAppsResults < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

   def change
     add_column :apps_results, :credential_id, :integer

     add_index :apps_results, :credential_id, algorithm: :concurrently
   end
 end
