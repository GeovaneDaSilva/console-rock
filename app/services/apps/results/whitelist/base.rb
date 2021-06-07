module Apps
  module Results
    module Whitelist
      # Base class for updating and merging value(s)
      # Into an app config for a given scope (Account or Device)
      # Creates new config at scope if one does not exist
      class Base
        def self.new(app, *args)
          klass = "Apps::Results::Whitelist::#{app.configuration_type.classify}".constantize

          if klass == self
            super
          else
            klass.new(app, *args)
          end
        end

        # app => App, scope => Account or Device,
        # value => String, target => Array
        def initialize(app, scope, value, target)
          @app = app
          @scope = scope
          @value = value
          @target = target
        end

        def call
          old_config = app_config.merged_config.with_indifferent_access

          updated_config = old_config.deep_merge(whitelist) do |_k, original_val, new_val|
            if original_val.is_a?(Array)
              (original_val + new_val).uniq
            else
              new_val
            end
          end

          app_config.update(config: updated_config)
        end

        private

        # Build hash object for config value
        # @target is array, like [:foo, :bar]
        # Outputs { foo: { bar: [@value] }}
        def whitelist
          @target.reverse.reduce([@value]) do |key, val|
            Hash[val, key]
          end
        end

        def app_config
          @app_config ||= @scope.app_configs.where(app: @app).first!
        rescue ActiveRecord::RecordNotFound
          @app_config = @scope.app_configs.new(app: @app)
        end
      end
    end
  end
end
