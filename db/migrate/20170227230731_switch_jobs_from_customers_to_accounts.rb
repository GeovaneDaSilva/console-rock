class SwitchJobsFromCustomersToAccounts < ActiveRecord::Migration[5.0]
  class Job < ApplicationRecord; end
  def change
    rename_column :jobs, :customer_id, :account_id

    Job.reset_column_information

    Job.all.find_each do |job|
      job.group = job.account.groups.first
      job.save
    end
  end
end
