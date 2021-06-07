# :nodoc
module Credentials
  # :nodoc
  module Update
    # :nodoc
    class DattoCredentials < Base
      def initialize
        @klass  = Credentials::Datto
        @script = "Integrations::Datto::ConnectionTest"
      end
    end
  end
end
