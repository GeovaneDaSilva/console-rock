module UpdateReports
  # Close out report billable instance records
  class BillableInstance
    def initialize(id_list)
      @billable_instance_ids = id_list
    end

    def call
      query = "update report_billable_instances set end_date = now() where billable_instance_id in #{ids}"
      ActiveRecord::Base.connection.execute(query)
    end

    private

    def ids
      "(#{@billable_instance_ids.join(', ')})"
    end
  end
end
