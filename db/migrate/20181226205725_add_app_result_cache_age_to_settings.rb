class AddAppResultCacheAgeToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :app_result_cache_age, :integer
    change_column_default :settings, :app_result_cache_age, from: nil, to: 86_400

    reversible do |dir|
      dir.up do
        Setting.reset_column_information

        Setting.update_all(app_result_cache_age: 86_400)
      end
    end
  end
end
