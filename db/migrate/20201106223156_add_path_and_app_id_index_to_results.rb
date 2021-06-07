class AddPathAndAppIdIndexToResults < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    [21, 22, 23, 24, 60, 61, 62, 63, 64, 65].each do |i|
      add_index :apps_results, :account_path, using: :gist, where: "app_id = #{i}",
                               algorithm: :concurrently,
                               name: "index_apps_results_on_account_path_where_app_id_#{i}"
    end
  end
end
