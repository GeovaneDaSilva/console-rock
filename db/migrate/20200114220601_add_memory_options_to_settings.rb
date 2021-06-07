class AddMemoryOptionsToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :max_memory_usage, :bigint
    add_column :settings, :max_sustained_memory_usage, :integer

    change_column_default :settings, :max_memory_usage, from: nil, to: 150_000_000
    change_column_default :settings, :max_sustained_memory_usage, from: nil, to: 600

    reversible do |dir|
      dir.up do
        Setting.update_all(
          max_memory_usage: 150_000_000,
          max_sustained_memory_usage: 600
        )
      end
    end
  end
end
