class AddPathAndAppIdIndexToAppsResults < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    20.times do |i|
      add_index :apps_results, :account_path, using: :gist, where: "app_id = #{i+1}",
                               algorithm: :concurrently,
                               name: "index_apps_results_on_account_path_where_app_id_#{i+1}"
    end
  end
end
