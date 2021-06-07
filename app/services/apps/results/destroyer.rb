module Apps
  module Results
    # Destroy all App Results within a scope
    class Destroyer
      include TriageScopeable
      attr_reader :params, :app

      # app => App, scope => Account or Device,
      # params => Hash
      def initialize(key, app, scope, params)
        @key = key
        @app = app
        @scope = scope
        @params = params.with_indifferent_access
      end

      def call
        selected_app_results.map(&:destroy)

        Rails.cache.write(@key, "completed")
      end

      private

      def app_results
        if @scope.is_a?(Device)
          @scope.app_results
        elsif @scope.is_a?(Account)
          @scope.all_descendant_app_results
        end
      end

      def total_count
        0
      end
    end
  end
end
