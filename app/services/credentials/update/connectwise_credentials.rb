# :nodoc
module Credentials
  # :nodoc
  module Update
    # :nodoc
    class ConnectwiseCredentials < Base
      def initialize
        @klass  = Credentials::Connectwise
        @script = "Integrations::Connectwise::ConnectionTest"
      end
    end
  end
end
