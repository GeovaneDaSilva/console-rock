module HuntResults
  AlreadyProcessed       = Class.new(StandardError)
  Unprocessable          = Class.new(StandardError)
  InternalError          = Class.new(StandardError)
  NetativeContinuousHunt = Class.new(StandardError)
  # Process a hunt result
  class Processor
    include ProcessorNotifications

    def initialize(hunt_result)
      @hunt_result = hunt_result
    end

    def call
      filter_hunt_result_for_processing!

      @hunt_result.update(manually_run: manually_run?)
      create_test_results!

      @hunt_result.result = overall_result
      raise NetativeContinuousHunt if @hunt_result.negative? && @hunt_result.hunt.continuous?
    rescue InternalError => e
      raise e, "Hunt ##{@hunt_result.hunt.id} was unable to execute properly. HR##{@hunt_result.id}."
    rescue Unprocessable
      # Rails.logger.info("Hunt ##{@hunt_result.hunt.id} had a test failure. HR##{@hunt_result.id}.")
    rescue AlreadyProcessed
      # Rails.logger.info("Hunt ##{@hunt_result.hunt.id} has already processed. HR##{@hunt_result.id}.")
    rescue NetativeContinuousHunt
      @hunt_result.destroy
    ensure
      ensure_hunt_result!
    end

    private

    def ensure_hunt_result!
      return true if @hunt_result.destroyed?

      Rails.cache.delete("device_#{@hunt_result.device.id}:hunt_#{@hunt_result.hunt.id}")
      @hunt_result.processed = true
      @hunt_result.save

      @hunt_result.device.queued_hunts.where(hunt: @hunt_result.hunt).destroy_all

      # notify_subscriptions!
      archive_older_results!
      broadcast_runner.perform_later("Broadcasts::Devices::Status", @hunt_result.device)
      broadcast_runner.perform_later("Broadcasts::Devices::Hunt", @hunt_result)
      broadcast_runner.perform_later("Broadcasts::Hunts::Status", @hunt_result.hunt)
      broadcast_runner.perform_later("AccountBroadcaster", @hunt_result.device.customer, "hunt")
    end

    def filter_hunt_result_for_processing!
      raise Unprocessable if @hunt_result.failure?
      raise InternalError if @hunt_result.error?
      raise AlreadyProcessed if @hunt_result.processed?
    end

    def create_test_results!
      results.each do |result|
        @hunt_result.test_results.create(
          test:    test_for_result(result.fetch("id")),
          result:  (result.fetch("result") == true ? :positive : :negative),
          details: result.fetch("details"),
          ttp:     ttps.find { |ttp| ttp.id == result.dig("ttp_id") }
        )
      end
    end

    def manually_run?
      results_json.fetch("manually_run", false)
    end

    def results
      @results ||= results_json.fetch("test_results", [])
    end

    def results_json
      @results_json ||= JSON.parse(
        ActiveSupport::Multibyte::Unicode.tidy_bytes(results_file.read, true)
      )
    end

    def results_file
      @results_file ||= Uploads::Downloader.new(@hunt_result.upload).call
    end

    def test_for_result(test_id)
      hunt_tests.find { |hunt_test| hunt_test.id == test_id }
    end

    def overall_result
      if @hunt_result.hunt.all_tests?
        @hunt_result.test_results.negative.any? ? :negative : :positive
      elsif @hunt_result.hunt.any_test?
        @hunt_result.test_results.positive.any? ? :positive : :negative
      end
    end

    def archive_older_results!
      HuntResult.where(
        hunt_id: @hunt_result.hunt_id, device: @hunt_result.device, revision: @hunt_result.revision,
        processed: true, archived: false
      ).where.not(id: @hunt_result.id).update_all(archived: true)
    end

    def broadcast_runner
      ServiceRunnerJob.set(queue: "ui")
    end

    def hunt_tests
      @hunt_tests ||= @hunt_result.hunt.tests.load.to_a
    end

    def ttps
      @ttps ||= TTP.find(
        results.collect { |result| result.dig("ttp_id") }.compact
      )
    end
  end
end
