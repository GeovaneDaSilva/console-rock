class RemoveNotNullOnApiExpiration < ActiveRecord::Migration[5.2]
  def change
    change_column_null :api_keys, :expiration, true
  end
end
