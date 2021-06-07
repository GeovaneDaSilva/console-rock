module Uploads
  # Queue Destroyer jobs for trashed Uploads
  class TrashedProcessor
    def call
      Upload.trashed.find_each do |upload|
        ServiceRunnerJob.set(queue: "utility", wait: rand_seconds).perform_later(
          "Uploads::Destroyer", upload
        )
      end

      true
    end

    private

    def rand_seconds
      SecureRandom.rand(1..10_000).seconds
    end
  end
end
