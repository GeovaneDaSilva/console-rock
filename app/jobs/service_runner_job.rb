# Run a service in the background
# Service must respond to #call with all arguments past
# at intitalization
# Change the queue at invocation, otherwise we'll run in default
class ServiceRunnerJob < ApplicationJob
  include ActiveJob::Status
  queue_as :default

  # Exception class to signal to the ServiceRunnerJob to retry
  # the job after some delay
  class IntermittentError < StandardError
    attr_reader :retry_wait

    def initialize(message = nil, retry_wait: 30.seconds)
      super message

      @retry_wait = retry_wait
    end
  end

  after_perform do
    Rails.cache.write(key, @result, expires_in: 60.minutes) if queue_name == "polled-tasks"
  end

  rescue_from IntermittentError do |error|
    retry_job wait: error.retry_wait
  end

  rescue_from ActiveJob::DeserializationError do |error|
    Rails.logger.fatal(
      "Service Runner Job queued with non-existant database record. #{error.message}:" \
      "#{@serialized_arguments.inspect}"
    )
  end

  # This job requires arguments, failsafe that they're provided at queue time
  def self.perform_later(*args)
    raise ArgumentError, "No arguments specified" if args.length.zero?

    super
  end

  def perform(klass_name, *args)
    return if ENV["NO_BG_QUEUE"]

    sample_transactions_for_scout_apm

    @result = klass_name.constantize.new(*args).call
    @result
  rescue DeviceMessages::DeviceNotFoundError
    nil
  end

  private

  def sample_transactions_for_scout_apm
    # sample 10% of transactions
    default_service_sample_rate = 0.1
    # sample 0.1% of transactions
    high_throughput_service_sample_rate = 0.001

    case queue_name
    when "pushed-tasks"
      sample_at(high_throughput_service_sample_rate)
    when "threat_evaluation"
      sample_at(high_throughput_service_sample_rate)
    when "ui"
      sample_at(high_throughput_service_sample_rate)
    when "default"
      sample_at(high_throughput_service_sample_rate)
    else
      sample_at(default_service_sample_rate)
    end
  end

  def sample_at(rate)
    ScoutApm::Transaction.ignore! if rand > rate
  end

  def key
    "polled-tasks/#{job_id}"
  end
end
