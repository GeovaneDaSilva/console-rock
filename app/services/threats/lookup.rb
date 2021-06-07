module Threats
  # Lookup module
  module Lookup
    ApiLimitExceeded = Class.new(StandardError)
    ApiError = Class.new(StandardError)
  end
end
