# frozen_string_literal: true

APP_ACTIONS = {
  data_discovery:        {
    scan_now: {
      name:        "Scan",
      description: "Initiate a Data Discovery scan"
    }
  },
  secure_now:            {
    reset: {
      name:        "Reset",
      description: "Reset the Active Directory Cache"
    }
  },
  vulnerability_scanner: {
    scan_now: {
      name:        "Scan",
      description: "Initiate a Host Vulnerability scan"
    }
  }
}.with_indifferent_access
