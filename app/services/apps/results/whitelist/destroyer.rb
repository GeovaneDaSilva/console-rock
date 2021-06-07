module Apps
  module Results
    module Whitelist
      # Removes all app results within a given scope
      # with a value at a given path
      class Destroyer
        # app => App, scope => Account or Device,
        # value => String, target => Array
        def initialize(app, scope, value, target)
          @app = app
          @scope = scope
          @value = value
          @target = target
        end

        def call
          count = 0

          app_results.find_each do |app_result|
            next unless app_result.values_at_path(@target).include?(@value)

            app_result.destroy
            count += 1
          end

          count
        end

        private

        def app_results
          if @scope.is_a?(Device)
            @scope.app_results.where(app: @app).where(incident_id: nil)
          elsif @scope.is_a?(Account)
            @scope.all_descendant_app_results
                  .without_incident
                  .where(app: @app)
          end
        end
      end
    end
  end
end
