class AddTextSearchExtensionSupportToPostgres < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      reversible do |dir|
        dir.up do
          execute "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;"
        end
        dir.down do
          execute "DROP EXTENSION IF EXISTS fuzzystrmatch;"
        end
      end
    end
  end
end
