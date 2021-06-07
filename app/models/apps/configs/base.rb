module Apps
  module Configs
    # Lookup the config class
    class Base
      def self.new(params)
        klass = "Apps::Configs::#{params.dig('custom')&.keys&.first&.to_s&.classify}".constantize
        klass.new(params)
      rescue NameError
        {}
      end
    end
  end
end
