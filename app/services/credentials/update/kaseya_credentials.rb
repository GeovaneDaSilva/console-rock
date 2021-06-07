# :nodoc
module Credentials
  # :nodoc
  module Update
    # :nodoc
    class KaseyaCredentials < Base
      def initialize
        @klass  = Credentials::Kaseya
        @script = "Integrations::Kaseya::ConnectionTest"
        @wait   = 8.hours
      end
    end
  end
end
