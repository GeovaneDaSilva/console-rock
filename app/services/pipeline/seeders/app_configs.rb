module Pipeline
  module Seeders
    # nodoc
    class AppConfigs
      def call
        seed_analysis_pipeline_configs(Apps::AccountConfig)
        seed_analysis_pipeline_configs(Apps::CustomConfig)
        seed_analysis_pipeline_configs(Apps::DeviceConfig)
      end

      private

      def sidekiq_pool
        @sidekiq_pool ||= Rails.application.config.pipeline_analysis_store
      end

      def send_data(data, type)
        sidekiq_pool.sadd("queues", "default")
        sidekiq_pool.lpush("queue:default", job_json(data, type))
      end

      def seed_analysis_pipeline_configs(type)
        total = type.count
        size = 50
        rounds = total / size + 1
        (1..rounds).each do |i|
          data = type.offset(500 * i).first(500).pluck(:app_id, :device_id, :account_id, :config)
          send_data(data, type)
        end
      end

      def job_json(data, type)
        {
          queue:       "default",
          # jid:         SecureRandom.hex(12),
          class:       "ReceiveJobsWorker",
          args:        ["UpdateFromConsoleJob", type.to_s, data],
          created_at:  Time.now.utc,
          enqueued_at: Time.now.utc,
          retry:       true
        }.to_json
      end
    end
  end
end
