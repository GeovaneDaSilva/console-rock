# Runs regular maintenance on the database
class DatabaseMaintenanceJob < ApplicationJob
  # performs maintenance on the indicated table
  class TableCleaningJob < ApplicationJob
    queue_as :maintenance
    sidekiq_options retry: false

    JobAlreadyRunningError = Class.new(StandardError)

    def perform(table_name)
      if job_running?(table_name)
        raise JobAlreadyRunningError, "#{self.class.name} already running on #{table_name}"
      end

      write_running_key!(table_name)
      DatabaseTimeout.timeout(job_time_limit) do
        ActiveRecord::Base.connection.execute("VACUUM ANALYZE #{table_name};")
      rescue StandardError => e
        delete_running_key!(table_name)
        raise e
      end
      delete_running_key!(table_name)
    end

    private

    def job_running_cache_key(table_name)
      ["v1/DatabaseMaintenanceJob", table_name]
    end

    def job_running?(table_name)
      Rails.cache.exist?(job_running_cache_key(table_name))
    end

    def write_running_key!(table_name)
      Rails.cache.write(job_running_cache_key(table_name), true, expires_in: job_time_limit)
    end

    def delete_running_key!(table_name)
      Rails.cache.delete(job_running_cache_key(table_name))
    end

    def job_time_limit
      6.hours
    end
  end

  queue_as :maintenance

  def perform
    tables.each do |table|
      TableCleaningJob.perform_later(table)
    end
  end

  private

  def tables
    %w[
      accounts
      apps_counter_caches
      apps_incidents
      apps_results
      billable_instances
      credentials
      devices
      devices_connectivity_logs
      firewall_counters
      psa_configs_cached_companies
      psa_configs_cached_company_types
      psa_configs_cached_company_types_companies
    ]
  end
end
