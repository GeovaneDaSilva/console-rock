module Sidekiq
  module Logging
    def self.job_hash_context(job_hash)
      # If we're using a wrapper class, like ActiveJob, use the "wrapped"
      # attribute to expose the underlying thing.
      klass = job_hash['wrapped'.freeze] || job_hash["class".freeze]

      klass = "ServiceRunnerJob::#{job_hash["args"][0]["arguments"][0]}" if klass == "ServiceRunnerJob"
      bid = job_hash['bid'.freeze]
      "#{klass} JID-#{job_hash['jid'.freeze]}#{" BID-#{bid}" if bid}"
    end
  end
end
