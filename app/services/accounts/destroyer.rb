module Accounts
  # Destroy an account and all sub-accounts
  # Removes dependent data first
  # Account may be a Provider or a Customer
  class Destroyer
    def initialize(key_or_account, account = nil)
      if key_or_account.is_a?(Account)
        @account = key_or_account
      else
        @key = key_or_account
        @account = account
      end
    end

    def call
      DatabaseTimeout.timeout(0) do
        uninstall_devices!
        destroy_all_hunts!

        @account.descendants.find_each do |sub_account|
          self.class.new(sub_account).call
        end

        @account.destroy
        Rails.cache.write(@key, "completed") if @key
      end
    end

    private

    def destroy_all_hunts!
      groups.find_each do |group|
        group.hunts.find_each do |hunt|
          Hunts::Destroyer.new(hunt).call
        end

        group.destroy
      end
    end

    def uninstall_devices!
      devices.find_each do |device|
        Devices::Destroy.new(device).call
      end
    end

    def devices
      @account.all_descendant_devices
    end

    def groups
      Group.where(account: @account.self_and_all_descendants)
    end
  end
end
