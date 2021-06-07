# :nodoc
module MsGraph
  # :nodoc
  module Services
    # :nodoc
    class Scheduler
      def initialize(target)
        @target = target
      end

      def call
        # TODO: generalize this for arbitrary params as well (even when need to pull from DB)
        Credentials::MsGraph.find_each do |cred|
          ServiceRunnerJob.perform_later(@target, cred.id)
        end
      end
    end
  end
end
