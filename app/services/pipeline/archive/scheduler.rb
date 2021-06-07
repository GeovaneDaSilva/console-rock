module Pipeline
  module Archive
    # nodoc
    class Scheduler
      def initialize
        @threshold = PIPELINE_CONFIGS.dig(:archive, :result_count_threshold) || 10_000
      end

      def call
        Customer.find_each do |customer|
          counter = customer.all_descendant_app_counter_caches.sum(:count)
          next if counter < @threshold

          ServiceRunnerJob.set(wait: generate_time).perform_later("Pipeline::Archive::Archiver", customer.id)
        end
      end

      private

      def generate_time
        (rand(0..3).hours + rand(0..30).minutes)
      end
    end
  end
end
