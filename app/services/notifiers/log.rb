module Notifiers
  # A notifier for test purposes
  class Log < Base
    def call
      Rails.logger.send(logger, message)
    end

    private

    def logger
      case @priority
      when :high
        :fatal
      when :medium
        :debug
      else
        :info
      end
    end

    def message
      "Event: #{@type.to_s.humanize} Account: #{@account.id} #{@payload}"
    end
  end
end
