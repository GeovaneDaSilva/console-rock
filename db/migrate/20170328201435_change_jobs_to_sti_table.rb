class ChangeJobsToStiTable < ActiveRecord::Migration[5.0]
  class Job < ApplicationRecord; end

  def change
    add_column :jobs, :type, :string, default: "Job", null: false
    add_column :jobs, :timezone, :string
    add_column :jobs, :targets, :string

    rename_table :jobs, :scheduled_tasks
    add_index :scheduled_tasks, [:type, :id]

    remove_column :groups, :jobs_count, :integer, default: 0
  end
end
