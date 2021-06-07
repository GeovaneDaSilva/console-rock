# :nodoc
module Credentials
  # :nodoc
  module Update
    # :nodoc
    class Base
      def call
        @klass.all.each do |cred|
          ServiceRunnerJob.perform_later(@script, { credential_id: cred.id })
        end
      end
    end
  end
end
