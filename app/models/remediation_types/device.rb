module RemediationTypes
  # nodoc
  class Device < Remediation
    belongs_to :device, class_name: "Device"
  end
end
