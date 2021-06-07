module DeviceBroadcasts
  # Publish call to all customers
  class Account < Base
    def initialize(account, message)
      @account = account
      @message = message
    end

    def call
      @account.self_and_all_descendant_customers.each do |customer|
        ServiceRunnerJob.perform_later("DeviceBroadcasts::Customer", customer, @message)
      end

      true
    end
  end
end
