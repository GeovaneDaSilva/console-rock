module Logging
  # responsible for
  class SidekiqLoggerFormatter < Sidekiq::Logging::LogstashFormatter
    def call(severity, time, progname, data)
      data = processed_data(data) if data.is_a?(Hash) && data.dig("args", 0, "arguments")
      message = super(severity, time, progname, data)
      "#{time.iso8601}#{progname_string(progname)}#{severity} -- : #{message}"
    rescue StandardError => e
      base_message = "Could not parse log"
      if data.is_a?(Hash)
        data[:logger_error] = true
        data[:logger_error_message] = base_message
        data[:logger_exception] = e.as_json
      elsif data.is_a?(String)
        data = { message:              data,
                 logger_error:         true,
                 logger_error_message: base_message,
                 logger_exception:     e.as_json }
      end
      super(severity, time, progname, data)
    end

    private

    def progname_string(progname)
      return " " if progname.nil?

      " [#{progname}] "
    end

    def processed_data(data)
      data["args"] = data["args"].map do |arg|
        if arg.dig("arguments")
          arg["arguments"] = arg["arguments"].map do |job_argument|
            if job_argument.is_a?(Hash) && job_argument.dig("_aj_globalid")
              job_argument["aj_globalid"] = job_argument.delete("_aj_globalid")
            end

            if job_argument.is_a?(Hash) && job_argument.dig("_aj_symbol_keys")
              job_argument["aj_symbol_keys"] = job_argument.delete("_aj_symbol_keys")
            end

            job_argument
          end
        end

        arg
      end

      data
    end
  end
end
