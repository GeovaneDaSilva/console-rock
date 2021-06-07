class ChangeArchiveStateDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :apps_results, :archive_state, from: nil, to: 0
  end
end
