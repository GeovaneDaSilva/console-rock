class AddJobsCountToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :jobs_count, :integer, default: 0

    Group.reset_column_information

    Group.all.find_each do |g|
      g.update(jobs_count: g.jobs.size)
    end
  end
end
