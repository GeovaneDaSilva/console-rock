module OtherApps
  # :nodoc
  class UpdateBillingStatus
    def initialize(account, paid)
      @accounts = account&.self_and_all_descendants&.where(plan_id: nil)&.pluck(:id)
      @accounts << account.id unless account.nil?
      @paid = paid
    end

    def call
      return if @accounts.blank?

      # ENV.fetch("BILLING_APP_UPDATE_LIST").each do |application|
      #   request = HTTPI.new
      #   request.url = ENV["#{application}_URL"]
      #   request.headers = ENV["#{application}_KEY"]
      #   @accounts.each do |acc_id|
      #     request.body = { account_id: acc_id, paid: @paid }
      #     HTTPI.post(request)
      #   end
      # end
    end
  end
end
