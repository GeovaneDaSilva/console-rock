module Analysis
  module Lookup
    # Base analysis service
    class Base
      MAX_RETRY = 10

      def initialize(analysis, count = 1)
        @analysis = analysis
        @count    = count
      end

      private

      def next_count
        @count + 1
      end

      def abandon!
        @analysis.abandoned!
        notify!
      end

      def notify!
        Analysis::Notifier.new(@analysis, @count).call
      end
    end
  end
end
