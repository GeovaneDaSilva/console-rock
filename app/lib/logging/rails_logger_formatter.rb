module Logging
  # Used to extend ActiveSupport::TaggedLogging::Formatter
  class RailsLoggerFormatter < ActiveSupport::Logger::SimpleFormatter
    def call(severity, timestamp, progname, message)
      "#{timestamp.iso8601}#{progname_string(progname)}#{severity} -- : #{message}\n"
    end

    private

    def progname_string(progname)
      return " " if progname.blank?

      " [#{progname}] "
    end
  end
end
