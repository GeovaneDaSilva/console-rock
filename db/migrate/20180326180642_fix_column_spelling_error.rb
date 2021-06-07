class FixColumnSpellingError < ActiveRecord::Migration[5.1]
  def change
    rename_column :hunts, :continious, :continuous
  end
end
