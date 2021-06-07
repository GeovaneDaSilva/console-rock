module Queries
  # updates the cache for a query
  class CacheUpdater
    class << self
      def call(*args)
        new(*args).call
      end
    end

    def initialize(klass, params)
      @klass = klass
      @params = params
    end

    attr_reader :params, :klass

    def call
      DatabaseTimeout.timeout(1.hour) do
        klass.constantize.new(*params).update_caches!
      end
    end
  end
end
