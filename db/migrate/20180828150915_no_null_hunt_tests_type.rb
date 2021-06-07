class NoNullHuntTestsType < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_column :hunts_tests, :type, :string, null: false
    end
  end
end
