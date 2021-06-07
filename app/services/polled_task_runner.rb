# Queues long running tasks in the background
class PolledTaskRunner
  attr_reader :key

  def initialize
    @key = "polled-tasks/#{SecureRandom.hex}"
    Rails.cache.write(@key, false)
  end

  def call(klass_name, *args)
    ServiceRunnerJob.set(queue: "polled-tasks").perform_later(klass_name, *([@key] + args))

    self
  end
end
