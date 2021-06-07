module Devices
  # Determine the type of device based on family attribute
  module Klassable
    extend ActiveSupport::Concern

    included do
      scope :windows, -> { where(family: "Windows") }
      scope :macos, -> { where(family: "macOS") }
    end

    def macos?
      family == "macOS"
    end

    def windows?
      family == "Windows"
    end
  end
end
