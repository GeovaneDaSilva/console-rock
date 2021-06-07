module Accounts
  # caches the list of descendant ids for a customer to enable more efficient
  # querying
  class SelfAndSubAccountsIdCacher
    class << self
      def fetch(account)
        new(account).fetch
      end

      def clear!(account)
        new(account).clear!
      end

      def reset!(account)
        new(account).reset!
      end

      def clear_self_and_ancestor_caches!(account)
        account.self_and_ancestors.find_each do |acct|
          new(acct).clear!
        end
      end
    end

    def initialize(account)
      @account = account
    end

    attr_reader :account

    def fetch
      Rails.cache.fetch(key, expires_in: expiry) do
        account.self_and_all_descendants.pluck(:id)
      end
    end

    def clear!
      Rails.cache.delete(key)
    end

    def reset!
      clear!
      fetch
    end

    private

    def key
      ["v1", self.class.name, "Account", account.id]
    end

    def expiry
      6.hours
    end
  end
end
