module Pipeline
  module Archive
    # nodoc
    class Destroyer
      def initialize(type, account_id)
        @type = type
        destroy_limit = PIPELINE_CONFIGS.dig(:archive, :destroy_limit)

        case type
        when "app_results"
          @customer = Customer.find(account_id)
          @victims = @customer.all_descendant_app_results.where(archive_state: :archived).take(destroy_limit)
          @victims ||= []
        else
          @victims = []
        end
      rescue ActiveRecord::RecordNotFound
        @victims = []
        Rails.logger.error("Archive Destroyer failed for type #{type} and account_id #{account_id}")
      end

      def call
        Rails.logger.fatal("ARCHIVE DESTROYER CALLED.  SHOULD NOT BE REACHING HERE")
        nil
        # return if @victims.blank?
        #
        # @victims.each(&:destroy)
        #
        # # TODO: a bad way to do it?  Want to limit, otherwise would need to do raw SQL
        #
        # case @type
        # when "app_results"
        #   unless @customer.all_descendant_app_results.where(archive_state: :archived).take.nil?
        #     ServiceRunnerJob.perform_later("Pipeline::Archive::Destroyer", @type, @customer.id)
        #   end
        # end
      end
    end
  end
end
