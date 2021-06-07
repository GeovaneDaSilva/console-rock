module Queries
  # updates the cache for a query
  class CacheClearer
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
      klass.constantize.new(*params).clear_caches!
    end
  end
end
