# frozen_string_literal: true

APP_WHITELISTS = {
  data_discovery:                    {
    "Path" => {
      # i.e. try app_result.details.file_path, so results must be schema-compliant all the way down
      result_paths: [%w[details file_path]],
      config_path:  %w[excluded_directories]
    }
  },
  cyberterrorist_network_connection: {
    "Remote IP"        => {
      result_paths: [%w[details remote_address]],
      config_path:  %w[excluded_ips]
    },
    "Process Filename" => {
      result_paths: [%w[details process exe_file_name]],
      config_path:  %w[process_exclusions]
    }
  },
  advanced_breach_detection:         {
    "Command Line Command" => {
      result_paths: [%w[details command_line], %w[details process command_line]],
      config_path:  %w[excluded_cli_commands]
    },
    "Parent Process"       => {
      result_paths: [
        %w[details parent file_name],
        %w[details process parent file_name],
        %w[details process parent parent file_name],
        %w[details process parent parent parent file_name],
        %w[details process parent parent parent parent file_name],
        %w[details process parent parent parent parent parent file_name],
        %w[details process parent parent parent parent parent parent file_name],
        %w[details process parent parent parent parent parent parent parent file_name],
        %w[details process parent parent parent parent parent parent parent parent file_name],
        %w[details process parent parent parent parent parent parent parent parent parent file_name],
        %w[details process parent parent parent parent parent parent parent parent parent parent file_name]
      ],
      config_path:  %w[excluded_parent_processes]
    },
    "Registry Key"         => {
      result_paths: [%w[details persistent_location]],
      config_path:  %w[excluded_registry_values]
    }
  },
  crypto_mining:                     {
    "Remote IP" => {
      result_paths: [%w[details remote_address]],
      config_path:  %w[excluded_ips]
    }
  },
  malicious_file_detection:          {
    "File Hash" => {
      result_paths: [%w[details md5]],
      config_path:  %w[excluded_hashes]
    },
    "Path"      => {
      result_paths: [%w[details dir_name]],
      config_path:  %w[excluded_paths]
    }
  },
  suspicious_network_services:       {
    "Path" => {
      result_paths: [%w[details process exe_file_name]],
      config_path:  %w[process_exclusions]
    }
  },
  suspicious_tools:                  {
    "Path"  => {
      result_paths: [
        %w[details path], %w[details files full_path], %w[details files path]
      ],
      config_path:  %w[excluded_paths]
    },
    "Title" => {
      result_paths: [%w[details displayname]],
      config_path:  %w[excluded_titles]
    }
  },
  office365:                         {
    "Action" => {
      result_paths: [%w[value]],
      config_path:  %w[exclusions]
    }
  },
  office365_signin:                  {
    "Email"   => {
      result_paths: [%w[details principalname]],
      config_path:  %w[exclusions]
    },
    "Country" => {
      result_paths: [%w[details country]],
      config_path:  %w[excluded_countries]
    }
  },
  syslog:                            {
    "Country"       => {
      result_paths: [%w[details country]],
      config_path:  %w[excluded_countries]
    },
    "Single IP"     => {
      result_paths: [%w[details remote_address]],
      config_path:  %w[excluded_ips]
    },
    "Source IP"     => {
      result_paths: [%w[details source_address]],
      config_path:  %w[excluded_ips]
    },
    "Firewall Rule" => {
      result_paths: [
        %w[details m],
        %w[details policyid],
        %w[details fw_rule_id],
        %w[details policyRuleId]
      ],
      config_path:  %w[excluded_firewall_rule]
    }
  },
  sentinelone:                       {
    "Threat"    => {
      result_paths: [%w[details threatname]],
      config_path:  %w[excluded_threats]
    },
    "Agent"     => {
      result_paths: [%w[details agentcomputername]],
      config_path:  %w[excluded_agents]
    },
    "Mitigated" => {
      result_paths: [%w[details mitigationstatus]],
      config_path:  %w[excluded_mitigation_statuses]
    },
    "Signed"    => {
      result_paths: [%w[details fileverificationtype]],
      config_path:  %w[excluded_signed_status]
    }
  },
  bitdefender:                       {
    "Threat"      => {
      result_paths: [%w[details threatname]],
      config_path:  %w[excluded_threats]
    },
    "Path"        => {
      result_paths: [%w[details filepath]],
      config_path:  %w[excluded_file_path]
    },
    "Endpoint"    => {
      result_paths: [%w[details endpointname]],
      config_path:  %w[excluded_endpoint_name]
    },
    "Endpoint IP" => {
      result_paths: [%w[details endpointip]],
      config_path:  %w[excluded_endpoint_ip]
    }
  },
  deep_instinct:                     {
    "Threat"      => {
      result_paths: [%w[details deep_classification]],
      config_path:  %w[excluded_threat_classification]
    },
    "Path"        => {
      result_paths: [%w[details file_hash]],
      config_path:  %w[excluded_file_path]
    },
    "Status"      => {
      result_paths: [%w[details status]],
      config_path:  %w[excluded_status]
    },
    "Last Action" => {
      result_paths: [%w[details last_action]],
      config_path:  %w[excluded_last_action]
    }
  },
  webroot:                           {
    "Threat"    => {
      result_paths: [%w[details malwaregroup]],
      config_path:  %w[excluded_malware]
    },
    "Agent"     => {
      result_paths: [%w[details hostname]],
      config_path:  %w[excluded_agents]
    },
    "File Name" => {
      result_paths: [%w[details filename]],
      config_path:  %w[excluded_file_name]
    }
  },
  cylance:                           {
    "Threat"    => {
      result_paths: [%w[details threat_name]],
      config_path:  %w[excluded_threats]
    },
    "Agent"     => {
      result_paths: [%w[details device_name]],
      config_path:  %w[excluded_agents]
    },
    "Mitigated" => {
      result_paths: [%w[details file_status]],
      config_path:  %w[excluded_mitigation_statuses]
    },
    "File Path" => {
      result_paths: [%w[details file_path]],
      config_path:  %w[excluded_file_path]
    }
  },
  dns_filter:                        {
    "Domain" => {
      result_paths: [%w[details domain]],
      config_path:  %w[excluded_domain]
    }
  },
  duo:                               {
    "Username" => {
      result_paths: [%w[details username]],
      config_path:  %w[excluded_user_name]
    },
    "Action"   => {
      result_paths: [%w[details action]],
      config_path:  %w[excluded_action]
    }
  },
  hibp:                              {
    "Title"  => {
      result_paths: [%w[details title]],
      config_path:  %w[excluded_threats]
    },
    "Domain" => {
      result_paths: [%w[details domain]],
      config_path:  %w[excluded_domain]
    }
  },
  ironscales:                        {
    "Threat"            => {
      result_paths: [%w[details classification]],
      config_path:  %w[excluded_threats]
    },
    "Sender Email"      => {
      result_paths: [%w[details sender_email]],
      config_path:  %w[excluded_sender_email]
    },
    "Sender Reputation" => {
      result_paths: [%w[details sender_reputation]],
      config_path:  %w[excluded_sender_reputation]
    },
    "Status"            => {
      result_paths: [%w[details themis_verdict]],
      config_path:  %w[excluded_status]
    }
  }
}.with_indifferent_access
