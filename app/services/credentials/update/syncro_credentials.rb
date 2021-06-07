# :nodoc
module Credentials
  # :nodoc
  module Update
    # :nodoc
    class SyncroCredentials < Base
      def initialize
        @klass  = Credentials::Syncro
        @script = "Integrations::Syncro::ConnectionTest"
      end
    end
  end
end
