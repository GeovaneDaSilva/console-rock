module Logging
  # extract additional logging parameters from sidekiq
  class SidekiqCustomOptions
    SidekiqCustomOptionsError = Class.new(StandardError)

    class << self
      def call(*args)
        new(*args).call
      end
    end

    def initialize(payload)
      @payload = payload
    end

    attr_accessor :payload

    # rubocop:disable Metrics/MethodLength
    def call
      return payload unless payload.respond_to?(:dig)

      payload["job_id"] = payload.dig("args", 0, "job_id")
      payload["sidekiq_jid"] = payload.dig("jid")
      payload["executor"] = payload.dig("wrapped")

      sidekiq_arguments = payload.dig("args", 0, "arguments")
      return payload unless sidekiq_arguments.is_a?(Array)
      return payload if sidekiq_arguments.blank?

      payload["service"] = sidekiq_arguments[0] if payload["executor"] == "ServiceRunnerJob"

      global_ids = sidekiq_arguments.select do |argument|
        argument.is_a?(Hash) && argument.dig(target).present?
      end

      return payload if global_ids.blank?

      global_ids.each do |hash|
        gid = hash.dig(target)
        # NOTE: this is expensive! When we get the application back under control
        # we should remove this and/or parse out the ID only from the GID string.
        # Fetching the record here is just a stop-gap for while our performance
        # issues continue
        record = GlobalID::Locator.locate(gid)
        payload[record.class.name.to_s.underscore.gsub("/", "_").downcase] = {
          id:         record.respond_to?(:id) && record.id,
          account_id: record.respond_to?(:account_id) && record.account_id,
          exists:     record.present?,
          global_id:  gid
        }
      end

      payload
    rescue StandardError => e
      error = SidekiqCustomOptionsError.new("Could not extract logging payload from event")
      output = error.as_json.merge({ cause: e.as_json })
      payload["logging_error"] = output.deep_symbolize_keys
      payload
    end
    # rubocop:enable Metrics/MethodLength

    private

    def sidekiq_arguments
      payload.dig("args", 0, "arguments")
    end

    def extract_global_ids!
      global_ids = sidekiq_arguments.select do |argument|
        argument.is_a?(Hash) && argument.dig(target).present?
      end

      return payload if global_ids.blank?

      global_ids.each do |hash|
        gid = hash.dig(target)
        parsed_gid = GlobalID.parse(gid)
        payload[parsed_gid.model_name.to_s.underscore.gsub("/", "_").downcase] = {
          id:        parsed_gid.model_id,
          global_id: gid
        }
      end
    end

    def target
      "_aj_globalid"
    end
  end
end
