module UpdateReports
  # Close out the report account record
  class Account
    def initialize(id)
      @account_id = id
    end

    def call
      query = "update report_accounts set end_date = now() where account_id = #{@account_id}"
      ActiveRecord::Base.connection.execute(query)
    end
  end
end
