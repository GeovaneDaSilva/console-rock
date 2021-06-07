# frozen_string_literal: true

APP_CONFIGS = {
  data_discovery:                    {
    removable_drives:     false,
    fixed_drives:         true,
    remote_drives:        false,
    directories:          %w[],
    excluded_directories: %w[%WINDIR% %PROGRAMFILES% %PROGRAMFILES(x86)%],
    scan_interval:        "Daily",
    scan_start_time:      1200,
    scan_types:           {
      payment_card:           {
        reporting_threshold: 1,
        scan_payment_data:   true,
        keywords:            ["ssn", "social_security", "payment", "card", "credit", "tax",
                              "visa", "amex", "american express", "mastercard", "discover",
                              "charge", "account", "bank", "amount", "debit", "statement",
                              "cardholder", "card holder", "diners", "maestro", "carte blanche",
                              "jcb", "solo", "switch", "cvv", "expiration", "postal", "zip",
                              "dob", "birthday", "expires", "zip code"],
        enabled_directories: [],
        enabled_brands:      %w[amex visa discover diners mastercard maestro carte_blanche jcb solo switch]
      },
      social_security_number: {
        label:               "Social Security Number",
        regex:               '\b((?!000)(?!666)([0-6]\d{2}|7[0-2][0-9]|73[0-3]|7[5-6][0-9]|77[0-1]))(\s|-)((?!00)\d{2})(\s|-)((?!0000)\d{4})\b',
        reporting_threshold: 1,
        keywords:            ["ssn", "social_security", "card", "tax", "account", "postal", "zip",
                              "dob", "birthday", "zip code", "social security"]
      },
      date_of_birth:          {
        label:               "Date of Birth",
        regex:               '\b(((0[13-9]|1[012])[-/]?(0[1-9]|[12][0-9]|30)|(0[13578]|1[02])[-/]?31|02[-/]?(0[1-9]|1[0-9]|2[0-8]))[-/]?[0-9]{4}|02[-/]?29[-/]?([0-9]{2}(([2468][048]|[02468][48])|[13579][26])|([13579][26]|[02468][048]|0[0-9]|1[0-6])00))\b',
        reporting_threshold: 1,
        keywords:            ["zip", "dob", "birthday", "zip code"]
      },
      zip_codes_us:           {
        label:               "Zip Codes (US)",
        regex:               '\b[0-9]{5}(?:-[0-9]{4})?\b',
        reporting_threshold: 1,
        keywords:            ["zip", "zip code", "postal", "address"]
      },
      email_address:          {
        label:               "Email Address",
        regex:               '\b[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,}\b',
        reporting_threshold: 1,
        keywords:            %w[email address username user name]
      }
    }
  },
  vulnerability_scanner:             {
    scan_interval:            "Weekly",
    scan_start_time:          1200,
    cvss_incident_threshould: 9.0
  },
  cyberterrorist_network_connection: {
    enabled_countries:                      {
      "A1" => { full_name: "Anonymous Proxy", enabled: true },
      "BY" => { full_name: "Belarus", enabled: true },
      "BI" => { full_name: "Burundi", enabled: true },
      "CF" => { full_name: "Central African Republic", enabled: true },
      "CN" => { full_name: "China", enabled: true },
      "CD" => { full_name: "Congo, The Democratic Republic of the", enabled: true },
      "CU" => { full_name: "Cuba", enabled: true },
      "IR" => { full_name: "Iran, Islamic Republic of", enabled: true },
      "IQ" => { full_name: "Iraq", enabled: true },
      "KP" => { full_name: "Democratic People's Republic of N. Korea", enabled: true },
      "LB" => { full_name: "Lebanon", enabled: true },
      "LY" => { full_name: "Libya", enabled: true },
      "RU" => { full_name: "Russian Federation", enabled: true },
      "SY" => { full_name: "Syria", enabled: true },
      "TJ" => { full_name: "Tajikistan", enabled: true },
      "TM" => { full_name: "Turkmenistan", enabled: true },
      "VE" => { full_name: "Venezula", enabled: true },
      "YE" => { full_name: "Yemen", enabled: true },
      "ZW" => { full_name: "Zimbabwe", enabled: true }
    },
    excluded_ips:                           %w[239.225.225.250 224.0.0.252 224.0.0.251],
    only_report_bad_reputation_connections: true,
    process_exclusions:                     []
  },
  system_process_verifier:           {
    excluded_cli_commands: []
  },
  secure_now:                        {
    url:                "https://api.pii-protect.com/directorysync/v1",
    client_id:          "",
    sync_interval:      60,
    hostname:           "",
    report_app_results: true
  },
  syslog:                            {
    listen_ip:            "",
    listen_port:          514,
    protocol:             "udp",
    forward_ip:           "",
    forward_port:         "",
    max_results:          1000,
    hostname:             "",
    save_raw_logs:        false,
    max_local_save_size:  10,
    priority_level:       "error",
    excluded_ips:         [],
    excluded_macs:        [],
    meraki:               {
      "ids-alerts"               => { "full_name" => "IDS signature match", "type" => "ids-alerts", "verdict" => "malicious", "enabled" => true },
      "rogue_ssid_detected"      => { "full_name" => "Rogue SSID detected", "type" => "rogue_ssid_detected", "verdict" => "malicious", "enabled" => true },
      "ssid_spoofing_detected"   => { "full_name" => "SSID spoofing detected", "type" => "ssid_spoofing_detected", "verdict" => "suspicious", "enabled" => true },
      "device_packet_flood"      => { "full_name" => "Packet flood detected", "type" => "device_packet_flood", "verdict" => "suspicious", "enabled" => true },
      "security_event_files"     => { "full_name" => "Malicious file detected", "type" => "security_event", "subtype" => "files", "verdict" => "suspicious", "enabled" => true },
      "security_event_ids_match" => { "full_name" => "IDS event match", "type" => "security_event", "subtype" => "ids_match", "verdict" => "suspicious", "enabled" => true },
      "user_login"               => { "full_name" => "Successful user login", "type" => "8021x_auth", "verdict" => "informational", "enabled" => true }
    },
    cisco:                {
      "2"  => { "full_name" => "TCP NULL flags attack", "asaID" => "%ASA-4-400026", "iosID" => "%IDS-4-TCP_FRAG_NULL_SIG", "rvrID" => "%RVR-4-TCPFRAGNULL", "verdict" => "suspicious", "enabled" => true },
      "3"  => { "full_name" => "IP fragment attack", "asaID" => "%ASA-4-400007", "iosID" => "%IDS-4-IPFRAG_ATTACK_SIG", "rvrID" => "%RVR-4-IPFRAG", "verdict" => "suspicious", "enabled" => true },
      "4"  => { "full_name" => "IP impossible packet attack", "asaID" => "%ASA-4-400008", "iosID" => "%IDS-4-IP_IMPOSSIBLE_SIG", "rvrID" => "%RVR-4-IPIMPOSSIBLE", "verdict" => "suspicious", "enabled" => true },
      "5"  => { "full_name" => "Fragmented ICMP traffic attack", "asaID" => "%ASA-4-400023", "iosID" => "%IDS-4-ICMP_FRAGMENT_SIG", "rvrID" => "%RVR-4-ICMPFRAGSIG", "verdict" => "suspicious", "enabled" => true },
      "6"  => { "full_name" => "Large ICMP traffic attack", "asaID" => "%ASA-4-400024", "iosID" => "%IDS-4-ICMP_TOOLARGE_SIG", "rvrID" => "%RVR-4-ICMPTOOLARGE", "verdict" => "suspicious", "enabled" => true },
      "7"  => { "full_name" => "Ping of death", "asaID" => "%ASA-4-400025", "iosID" => "%IDS-4-ICMP_PING_OF_DEATH_SIG", "rvrID" => "%RVR-4-ICMPPINGOFDEATH", "verdict" => "suspicious", "enabled" => true },
      "8"  => { "full_name" => "TCP SYN+FIN flag attack", "asaID" => "%ASA-4-400027", "iosID" => "%IDS-4-TCP_FRAG_SYN_FIN_SIG", "rvrID" => "%RVR-4-TCPFRAGSYNFIN", "verdict" => "suspicious", "enabled" => true },
      "9"  => { "full_name" => "TCP FIN flag attack", "asaID" => "%ASA-4-400028", "iosID" => "%IDS-4-TCP_FIN_ONLY_SIG", "rvrID" => "%RVR-4-TCPFRAGFIN", "verdict" => "suspicious", "enabled" => true },
      "10" => { "full_name" => "Proxied RPC request", "asaID" => "%ASA-4-400041", "iosID" => "%IDS-4-RPC_CALLIT_REQUEST", "rvrID" => "%RVR-4-CALLIT", "verdict" => "suspicious", "enabled" => true },
      "11" => { "full_name" => "FTP improper port specified", "asaID" => "%ASA-4-400030", "iosID" => "%IDS-4-UNAVAILABLE", "rvrID" => "%RVR-4-UNAVAILABLEPORT", "verdict" => "suspicious", "enabled" => true },
      "12" => { "full_name" => "UDP bomb", "asaID" => "%ASA-4-400031", "iosID" => "%IDS-4-UDP_BOMB_SIG", "rvrID" => "%RVR-4-UDPBOMB", "verdict" => "suspicious", "enabled" => true },
      "13" => { "full_name" => "UDP Snork attack", "asaID" => "%ASA-4-400032", "iosID" => "%IDS-4-UDP_SNORK_SIG", "rvrID" => "%RVR-4-SNORK", "verdict" => "suspicious", "enabled" => true },
      "14" => { "full_name" => "UDP Chargen DoS attack", "asaID" => "%ASA-4-400033", "iosID" => "%IDS-4-UDP_CHARGEN_DOS_SIG", "rvrID" => "%RVR-4-UDPCHARGE", "verdict" => "suspicious", "enabled" => true },
      "15" => { "full_name" => "Successful admin login", "asaID" => "%ASA-6-605005", "iosID" => "%SEC_LOGIN-5-LOGIN_SUCCESS", "verdict" => "informational", "enabled" => true }
    },
    fortinet:             {
      "12" => { "full_name" => "FortiGuard block events", "type" => "webfilter", "subtype" => "ftgd_block", "verdict" => "suspicious", "enabled" => true },
      "02" => { "full_name" => "ActiveX allow events", "type" => "webfilter", "subtype" => "activex_allow", "verdict" => "suspicious", "enabled" => true },
      "03" => { "full_name" => "Intrusion attempts  (App Control)", "type" => "app-ctrl", "verdict" => "suspicious", "enabled" => true },
      "04" => { "full_name" => "Intrusion attempts (general)", "type" => "anomaly", "verdict" => "malicious", "enabled" => true },
      "05" => { "full_name" => "Antivirus alerts", "type" => "virus", "verdict" => "malicious", "enabled" => true },
      "06" => { "full_name" => "Data leaks", "type" => "dlp", "verdict" => "suspicious", "enabled" => true },
      "07" => { "full_name" => "IPS detections", "type" => "ips", "verdict" => "malicious", "enabled" => true },
      "08" => { "full_name" => "System security audit events", "type" => "event", "subtype" => "securityaudit", "verdict" => "suspicious", "enabled" => true },
      "15" => { "full_name" => "SSL VPN tunnel down", "type" => "event", "subtype" => "vpn", "action" => "tunnel-down", "verdict" => "suspicious", "enabled" => true },
      "21" => { "full_name" => "FortiClient connection closed", "type" => "event", "subtype" => "endpoint", "action" => "sslvpn_close", "verdict" => "suspicious", "enabled" => true }
    },
    sonicwall:            {
      "30"   => { "full_name" => "Admin login failure", "verdict" => "suspicious", "enabled" => true },
      "31"   => { "full_name" => "Local user login allowed", "verdict" => "informational", "enabled" => true },
      "32"   => { "full_name" => "User login failure", "verdict" => "suspicious", "enabled" => true },
      "33"   => { "full_name" => "User credential failure", "verdict" => "suspicious", "enabled" => true },
      "35"   => { "full_name" => "Attack suspected", "verdict" => "suspicious", "enabled" => true },
      "41"   => { "full_name" => "Dropped unknown protocol", "verdict" => "suspicious", "enabled" => true },
      "159"  => { "full_name" => "AV Expired", "verdict" => "suspicious", "enabled" => true },
      "18"   => { "full_name" => "ActiveX access attempt", "verdict" => "informational", "enabled" => true },
      "19"   => { "full_name" => "Java access failure", "verdict" => "informational", "enabled" => true },
      "20"   => { "full_name" => "ActiveX/Java archive access failure", "verdict" => "informational", "enabled" => true },
      "21"   => { "full_name" => "Blocked cookie", "verdict" => "informational", "enabled" => true },
      "22"   => { "full_name" => "Ping of death", "verdict" => "informational", "enabled" => true },
      "23"   => { "full_name" => "IP spoofing", "verdict" => "informational", "enabled" => true },
      "25"   => { "full_name" => "SYN flood", "verdict" => "informational", "enabled" => true },
      "27"   => { "full_name" => "Land attack", "verdict" => "informational", "enabled" => true },
      "70"   => { "full_name" => "IPsec to/from illegal host", "verdict" => "informational", "enabled" => true },
      "81"   => { "full_name" => "Smurf attack", "verdict" => "informational", "enabled" => true },
      "82"   => { "full_name" => "Port scan (low confidence)", "verdict" => "informational", "enabled" => true },
      "83"   => { "full_name" => "Port scan (high confidence)", "verdict" => "informational", "enabled" => true },
      "143"  => { "full_name" => "Attack (general)", "verdict" => "informational", "enabled" => true },
      "165"  => { "full_name" => "Suspicious email attachment", "verdict" => "informational", "enabled" => true },
      "177"  => { "full_name" => "TCP FIN scan", "verdict" => "informational", "enabled" => true },
      "178"  => { "full_name" => "TCP XMAS scan", "verdict" => "informational", "enabled" => true },
      "179"  => { "full_name" => "TCP NULL scan", "verdict" => "informational", "enabled" => true },
      "180"  => { "full_name" => "IPsec replay attack", "verdict" => "informational", "enabled" => true },
      "229"  => { "full_name" => "IP spoofing to  Central Gateway", "verdict" => "informational", "enabled" => true },
      "248"  => { "full_name" => "Malicious email attachment", "verdict" => "informational", "enabled" => true },
      "267"  => { "full_name" => "TCP XMAS (high confidence)", "verdict" => "informational", "enabled" => true },
      "329"  => { "full_name" => "IP lockout - excessive login failures", "verdict" => "informational", "enabled" => true },
      "446"  => { "full_name" => "PASV FTP spoofing", "verdict" => "informational", "enabled" => true },
      "527"  => { "full_name" => "FTP bounce attack (PORT)", "verdict" => "informational", "enabled" => true },
      "528"  => { "full_name" => "FTP bounce attack (PASV)", "verdict" => "informational", "enabled" => true },
      "546"  => { "full_name" => "Rogue access point detection", "verdict" => "informational", "enabled" => true },
      "548"  => { "full_name" => "Association  flood  from WLAN station", "verdict" => "informational", "enabled" => true },
      "606"  => { "full_name" => "Spank attack (multicast)", "verdict" => "informational", "enabled" => true },
      "608"  => { "full_name" => "IPS detection (general)", "verdict" => "informational", "enabled" => true },
      "609"  => { "full_name" => "IPS prevention (general)", "verdict" => "informational", "enabled" => true },
      "789"  => { "full_name" => "IPS high priority detection", "verdict" => "informational", "enabled" => true },
      "790"  => { "full_name" => "IPS high priority prevention", "verdict" => "informational", "enabled" => true },
      "794"  => { "full_name" => "Anti-spyware prevention", "verdict" => "informational", "enabled" => true },
      "795"  => { "full_name" => "Anti-spyware detection", "verdict" => "informational", "enabled" => true },
      "809"  => { "full_name" => "Gateway antivirus alert", "verdict" => "informational", "enabled" => true },
      "1098" => { "full_name" => "DNS rebind attack", "verdict" => "informational", "enabled" => true },
      "1200" => { "full_name" => "Suspected botnet initiator blocked", "verdict" => "informational", "enabled" => true },
      "1201" => { "full_name" => "Suspected botnet responder blocked", "verdict" => "informational", "enabled" => true },
      "1213" => { "full_name" => "UDP flood attack", "verdict" => "informational", "enabled" => true },
      "1214" => { "full_name" => "ICMP flood attack", "verdict" => "informational", "enabled" => true },
      "1316" => { "full_name" => "ARP attack", "verdict" => "informational", "enabled" => true },
      "1363" => { "full_name" => "Wireless flood attack", "verdict" => "informational", "enabled" => true },
      "1376" => { "full_name" => "Nestea/Teardrop attack", "verdict" => "informational", "enabled" => true },
      "1378" => { "full_name" => "Possible replay attack", "verdict" => "informational", "enabled" => true }
    },
    sophos:               {
      "01" => { "full_name" => "Advanced threat detection", "log_type" => "ATP", "log_subtype" => "Alert", "verdict" => "malicious", enabled: true },
      "03" => { "full_name" => "Suspicious firewall authentications", "log_type" => "Event", "log_subtype" => "Authentication", "verdict" => "suspicious", enabled: true },
      "04" => { "full_name" => "Data leaks", "log_type" => "Anti-Spam", "log_subtype" => "DLP", "verdict" => "suspicious", enabled: true },
      "05" => { "full_name" => "Denial of service attack", "log_type" => "Anti-Spam", "log_subtype" => "Dos", "verdict" => "informational", enabled: true },
      "07" => { "full_name" => "Internal compromise check (high confidence)", "log_type" => "Anti-Spam", "log_subtype" => "Outbound Spam", "verdict" => "malicious", enabled: true },
      "10" => { "full_name" => "Antivirus detections", "log_type" => "Anti-Virus", "log_subtype" => "Virus", "verdict" => "suspicious", enabled: true },
      "11" => { "full_name" => "Probably Unwanted Applications (PUAs)", "log_type" => "Anti-virus", "log_subtype" => "PUA", "verdict" => "suspicious", enabled: true },
      "13" => { "full_name" => "IDS/IPS detections (high confidence)", "log_type" => "IDP", "log_subtype" => "Detect", "log_component" => "Signatures", "verdict" => "informational", enabled: true }
    },
    watchguard:           {
      "02" => { "full_name" => "SYN flood attack", "message_ids" => "3000-0153 3000-0162", "verdict" => "informational", enabled: true },
      "07" => { "full_name" => "DDOS attack", "message_ids" => "3000-0161", "verdict" => "informational", enabled: true },
      "08" => { "full_name" => "Port scan", "message_ids" => "3000-0159", "verdict" => "informational", enabled: true },
      "09" => { "full_name" => "IPS detection (general)", "message_ids" => "3000-0150 1AFF-0025 1BFF-0011 1CFF-000D 1DFF-0010 2AFF-0006 2DFF-0001 21FF-000C", "verdict" => "informational", enabled: true },
      "11" => { "full_name" => "Advanced Persistent Threat detection", "message_ids" => "1AFF-0034 1BFF-0028 1CFF-0015 21FF-001F", "verdict" => "malicious", enabled: true },
      "12" => { "full_name" => "Data leak", "message_ids" => "1BFF-0024 1CFF-0011 1AFF-002F", "verdict" => "suspicious", enabled: true },
      "14" => { "full_name" => "IP spoofing", "message_ids" => "3000-0169", "verdict" => "suspicious", enabled: true },
      "15" => { "full_name" => "ARP spoofing", "message_ids" => "3000-012C", "verdict" => "suspicious", enabled: true },
      "16" => { "full_name" => "IPS license expired (notification)", "message_ids" => "3000-0005", "verdict" => "informational", enabled: true },
      "17" => { "full_name" => "Rogue Access Point detection", "message_ids" => "6100-000C", "verdict" => "informational", enabled: true },
      "20" => { "full_name" => "Administrator login", "message_ids" => "3E00-0002", "verdict" => "informational", "enabled" => true }
    },
    untangle:             {
      "01" => { "full_name" => "Content checks (probably unwanted content)", "class" => "WebFilterEvent", "category" => "Anonymizer,Child Inappropriate,Spyware & Questionable Software", "verdict" => "suspicious", enabled: true },
      "02" => { "full_name" => "Content checks (illegal activity)", "class" => "WebFilterEvent", "category" => "Child Abuse Images", "verdict" => "malicious", enabled: true },
      "03" => { "full_name" => "Content checks (malicious sites)", "class" => "WebFilterEvent", "category" => "Botnet,Compromised,Malware Call-Home,Malware Distribution Point,Phishing/Fraud", "verdict" => "malicious", enabled: true },
      "04" => { "full_name" => "Content checks (remote access tools)", "class" => "WebFilterEvent", "category" => "Remote Access", "verdict" => "suspicious", enabled: true },
      "06" => { "full_name" => "Authentication monitoring (high value targets)", "class" => "AdminLoginEvent", "success" => "failed", "verdict" => "malicious", enabled: true },
      "07" => { "full_name" => "Authentication monitoring (general)", "class" => "LoginEvent", "verdict" => "suspicious", enabled: true },
      "08" => { "full_name" => "Potential compromise (high confidence)", "class" => "IntrusionPreventionLogEvent", "rid" => "1810,1811,1900,2412,2271", "verdict" => "suspicious", enabled: true },
      "12" => { "full_name" => "Successful admin login", "class" => "AdminLoginEvent", "succeeded" => "true", "verdict" => "informational", enabled: true }
    },
    barracuda:            {
      "01" => { "full_name" => "Attempted Access not covered by Firewall Rules", "id" => "BLOCKALL", "log_file" => "box_Firewall_Activity", "verdict" => "informational", enabled: true },
      "02" => { "full_name" => "User quarantined alert", "id" => "5000", "log_file" => "box_Event_eventS", "verdict" => "informational", enabled: true },
      "03" => { "full_name" => "ATP alert (malicious)", "id" => "5001", "log_file" => "box_Event_eventS", "verdict" => "informational", enabled: true },
      "04" => { "full_name" => "DNS Sinkhole", "id" => "5004", "log_file" => "box_Event_eventS", "verdict" => "informational", enabled: true },
      "05" => { "full_name" => "Anti-Virus", "id" => "5005", "log_file" => "box_Event_eventS", "verdict" => "informational", enabled: true },
      "06" => { "full_name" => "ATP (file block)", "id" => "File", "log_file" => "srv_S1_AV", "verdict" => "informational", enabled: true },
      "07" => { "full_name" => "System login notice", "id" => "4130", "log_file" => "box_Event_eventS", "verdict" => "informational", enabled: true }
    },
    ubiquiti:             {
      "01" => { "full_name" => "IP blacklisted (OpenProxies)", "rule" => "ASL_OPENPROXIES_BLOCK", "verdict" => "suspicious", enabled: true },
      "02" => { "full_name" => "IP blacklisted (OpenBL)", "rule" => "ASL_OPENBL_BLOCK", "verdict" => "suspicious", enabled: true },
      "03" => { "full_name" => "Emerging threats", "rule" => "ASL_EMERGING_THREATS_BLOCK", "verdict" => "suspicious", enabled: true },
      "04" => { "full_name" => "Suspicious origin IP", "rule" => "ASL_GEO_BLOCK", "verdict" => "suspicious", enabled: true },
      "05" => { "full_name" => "IP blacklisted (ASL)", "rule" => "ASL_BLACKLIST_BLOCK", "verdict" => "suspicious", enabled: true },
      "06" => { "full_name" => "DDOS attack via NTP amplifier", "rule" => "DROP_ASL: NTP_DDOS", "verdict" => "malicious", enabled: true },
      "07" => { "full_name" => "DDOS attack via DNS amplifier", "rule" => "DROP_ASL: DNS_DDOS", "verdict" => "malicious", enabled: true },
      "08" => { "full_name" => "HeartBleed attack", "rule" => "DROP_ASL: HEARTBEAT", "verdict" => "malicious", enabled: true }
    },
    pfsense:              {
      "01" => { "full_name" => "Malware", "sig_id" => "105 141 144 146 161 162 163 185 209 212 218 219 220", "verdict" => "suspicious", enabled: true },
      "02" => { "full_name" => "DoS Attack", "sig_id" => "221 226 228 231 234 237 238 239 240 243 244 245 246 247 248 250", "verdict" => "suspicious", enabled: true },
      "03" => { "full_name" => "DNS Spoof Attack", "sig_id" => "253 254", "verdict" => "suspicious", enabled: true },
      "04" => { "full_name" => "Communication from malicious URL", "sig_id" => "17904 21246 21255 21256 21257 21475 22958 22960 24031 24032 24033 26396 26401 26402 26405", "verdict" => "suspicious", enabled: true },
      "05" => { "full_name" => "Administrator login successful", "sig_id" => "340", "verdict" => "informational", enabled: true }
    },
    juniper:              {
      "01" => { "full_name" => "IDS system event", "event_category" => "RT_IDS", "verdict" => "suspicious", enabled: true },
      "02" => { "full_name" => "IDS protection event", "event_category" => "RT_IDP", "verdict" => "suspicious", enabled: true },
      "03" => { "full_name" => "IP reputation monitoring", "event_category" => "RT_FLOW", "verdict" => "suspicious", enabled: true },
      "04" => { "full_name" => "Telnet login authentication failure", "event_category" => "FWAUTH_TELNET_USER_AUTH_FAIL", "verdict" => "suspicious", enabled: true },
      "05" => { "full_name" => "FTP login authentication failure", "event_category" => "FWAUTH_FTP_USER_AUTH_FAIL", "verdict" => "suspicious", enabled: true },
      "06" => { "full_name" => "HTTP user login authentication failure", "event_category" => "FWAUTH_HTTP_USER_AUTH_FAIL", "verdict" => "suspicious", enabled: true },
      "07" => { "full_name" => "Web user login authentication failure", "event_category" => "FWAUTH_WEBAUTH_FAIL", "verdict" => "suspicious", enabled: true },
      "08" => { "full_name" => "Admin login", "event_category" => "LOGIN_ROOT", "verdict" => "informational", enabled: true }
    },
    sophos_utm:           {
      "01" => { "full_name" => "Virus or Malware Detection", "id" => "#0056", "sys" => "SecureWeb", "sub" => "http", "verdict" => "suspicious", enabled: true },
      "02" => { "full_name" => "Potentially Unwanted Application (PUA) blocked", "id" => "#0057", "sys" => "SecureWeb", "sub" => "http", "verdict" => "suspicious", enabled: true },
      "03" => { "full_name" => "Blocked by URL filter", "id" => "#0060", "sys" => "SecureWeb", "sub" => "http", "verdict" => "suspicious", enabled: true },
      "04" => { "full_name" => "Attempted connection to forbidden country", "id" => "#0067", "sys" => "SecureWeb", "sub" => "http", "verdict" => "suspicious", enabled: true },
      "05" => { "full_name" => "Request blocked by Advanced Threat Protection (ATP)", "id" => "#0068", "sys" => "SecureWeb", "sub" => "http", "verdict" => "suspicious", enabled: true },
      "06" => { "full_name" => "ICMP redirect attack", "id" => "#2009", "sys" => "SecureNet", "sub" => "packetfilter", "verdict" => "suspicious", enabled: true },
      "07" => { "full_name" => "Intrusion Protection System (IPS) alert", "id" => "#2101", "sys" => "SecureNet", "sub" => "ips", "verdict" => "suspicious", enabled: true },
      "08" => { "full_name" => "User Login Failure", "id" => "#3006", "sys" => "System", "sub" => "auth", "verdict" => "suspicious", enabled: true },
      "09" => { "full_name" => "User Login Success", "id" => "#3004", "sys" => "System", "sub" => "auth", "verdict" => "suspicious", enabled: true }
    },
    zyxel:                {
      "02" => { "full_name" => "TCP IP Spoofing Attack", "msg" => "ip spoofing - no routing entry TCP", "verdict" => "malicious", enabled: true },
      "03" => { "full_name" => "UDP IP Spoofing Attack", "msg" => "ip spoofing - no routing entry UDP", "verdict" => "malicious", enabled: true },
      "04" => { "full_name" => "ICMP Source Quench Attack", "msg" => "ICMP Source Quench ICMP", "verdict" => "malicious", enabled: true },
      "05" => { "full_name" => "ICMP Time Exceeded Attack", "msg" => "ICMP Time Exceed ICMP", "verdict" => "suspicious", enabled: true },
      "07" => { "full_name" => "Ping of Death", "msg" => "ping of death. ICMP", "verdict" => "malicious", enabled: true },
      "08" => { "full_name" => "FTP Blocked Per Management Settings", "msg" => "Remote Management: FTP denied", "verdict" => "suspicious", enabled: true },
      "09" => { "full_name" => "TELNET Blocked per Management Settings", "msg" => "Remote Management: TELNET denied", "verdict" => "suspicious", enabled: true },
      "10" => { "full_name" => "HTTP or UPnP Blocker Per Management Settings", "msg" => "Remote Management: HTTP or UPnP denied", "verdict" => "suspicious", enabled: true },
      "11" => { "full_name" => "WWW Service Blocked Per Management Settings", "msg" => "Remote Management: WWW denied", "verdict" => "suspicious", enabled: true },
      "12" => { "full_name" => "HTTPS Service Blocked Per Management Settings", "msg" => "Remote Management: HTTPS denied", "verdict" => "suspicious", enabled: true },
      "13" => { "full_name" => "DNS Service Blocked Per Management Settings", "msg" => "Remote Management: DNS denied", "verdict" => "suspicious", enabled: true },
      "14" => { "full_name" => "Successful Web Login", "msg" => "Successful WEB login", "verdict" => "suspicious", enabled: true },
      "15" => { "full_name" => "Successful Telnet Login", "msg" => "TELNET Login Successful", "verdict" => "suspicious", enabled: true },
      "16" => { "full_name" => "Successful FTP Login", "msg" => "Successful FTP login", "verdict" => "suspicious", enabled: true }
    },
    mikrotik:             {
      "01" => { "full_name" => "Administator Login", "topic" => "system,info,account", "action" => "admin logged in", "verdict" => "informational", enabled: true },
      "02" => { "full_name" => "Administrator Logout", "topic" => "system,info,account", "action" => "admin logged out", "verdict" => "informational", enabled: true },
      "03" => { "full_name" => "Login Failure", "topic" => "system,error,critical", "action" => "login failure", "verdict" => "suspicious", enabled: true },
      "04" => { "full_name" => "Incoming LAN packets without a valid IP Address", "topic" => "firewall,info", "action" => "LAN_!LAN", "verdict" => "suspicious", enabled: true },
      "05" => { "full_name" => "Incoming packets from a none public IP Address", "topic" => "firewall,info", "action" => "!public", "verdict" => "suspicious", enabled: true },
      "06" => { "full_name" => "Incoming packets that are not NAT`ted", "topic" => "firewall,info", "action" => "!NAT", "verdict" => "suspicious", enabled: true },
      "07" => { "full_name" => "Incoming packets from invalid connections", "topic" => "firewall,info", "action" => "!public_from_LAN", "verdict" => "informational", enabled: true },
      "08" => { "full_name" => "Incoming packets from none public LAN addresses", "topic" => "firewall,info", "action" => "!public_from_LAN", "verdict" => "informational", enabled: true },
      "09" => { "full_name" => "All custom rules", "topic" => "firewall,info", "action" => "match all", "verdict" => "informational", enabled: true }
    },
    suspicious_countries: {
      "US" => { full_name: "United States", enabled: false },
      "AF" => { full_name: "Afghanistan", enabled: true },
      "AX" => { full_name: "Åland Islands", enabled: true },
      "AL" => { full_name: "Albania", enabled: true },
      "DZ" => { full_name: "Algeria", enabled: true },
      "AS" => { full_name: "American Samoa", enabled: true },
      "AD" => { full_name: "Andorra", enabled: true },
      "AO" => { full_name: "Angola", enabled: true },
      "AI" => { full_name: "Anguilla", enabled: true },
      "A1" => { full_name: "Anonymous Proxy", enabled: true },
      "AG" => { full_name: "Antigua and Barbuda", enabled: true },
      "AR" => { full_name: "Argentina", enabled: true },
      "AM" => { full_name: "Armenia", enabled: true },
      "AW" => { full_name: "Aruba", enabled: true },
      "AU" => { full_name: "Australia", enabled: true },
      "AT" => { full_name: "Austria", enabled: true },
      "AZ" => { full_name: "Azerbaijan", enabled: true },
      "BS" => { full_name: "Bahamas", enabled: true },
      "BH" => { full_name: "Bahrain", enabled: true },
      "BD" => { full_name: "Bangladesh", enabled: true },
      "BB" => { full_name: "Barbados", enabled: true },
      "BY" => { full_name: "Belarus", enabled: true },
      "BE" => { full_name: "Belgium", enabled: true },
      "BZ" => { full_name: "Belize", enabled: true },
      "BJ" => { full_name: "Benin", enabled: true },
      "BM" => { full_name: "Bermuda", enabled: true },
      "BT" => { full_name: "Bhutan", enabled: true },
      "BO" => { full_name: "Bolivia", enabled: true },
      "BA" => { full_name: "Bosnia and Herzegovina", enabled: true },
      "BW" => { full_name: "Botswana", enabled: true },
      "BR" => { full_name: "Brazil", enabled: true },
      "BQ" => { full_name: "British Antarctic Territory", enabled: true },
      "IO" => { full_name: "British Indian Ocean Territory", enabled: true },
      "VG" => { full_name: "British Virgin Islands", enabled: true },
      "BN" => { full_name: "Brunei", enabled: true },
      "BG" => { full_name: "Bulgaria", enabled: true },
      "BF" => { full_name: "Burkina Faso", enabled: true },
      "BI" => { full_name: "Burundi", enabled: true },
      "KH" => { full_name: "Cambodia", enabled: true },
      "CM" => { full_name: "Cameroon", enabled: true },
      "CA" => { full_name: "Canada", enabled: true },
      "CV" => { full_name: "Cape Verde", enabled: true },
      "KY" => { full_name: "Cayman Islands", enabled: true },
      "CF" => { full_name: "Central African Republic", enabled: true },
      "TD" => { full_name: "Chad", enabled: true },
      "CL" => { full_name: "Chile", enabled: true },
      "CN" => { full_name: "China", enabled: true },
      "CO" => { full_name: "Colombia", enabled: true },
      "KM" => { full_name: "Comoros", enabled: true },
      "CG" => { full_name: "Congo - Brazzaville", enabled: true },
      "CD" => { full_name: "Congo - Kinshasa", enabled: true },
      "CK" => { full_name: "Cook Islands", enabled: true },
      "CR" => { full_name: "Costa Rica", enabled: true },
      "HR" => { full_name: "Croatia", enabled: true },
      "CU" => { full_name: "Cuba", enabled: true },
      "CY" => { full_name: "Cyprus", enabled: true },
      "CZ" => { full_name: "Czech Republic", enabled: true },
      "CI" => { full_name: "Côte d’Ivoire", enabled: true },
      "DK" => { full_name: "Denmark", enabled: true },
      "DJ" => { full_name: "Djibouti", enabled: true },
      "DM" => { full_name: "Dominica", enabled: true },
      "DO" => { full_name: "Dominican Republic", enabled: true },
      "EC" => { full_name: "Ecuador", enabled: true },
      "EG" => { full_name: "Egypt", enabled: true },
      "SV" => { full_name: "El Salvador", enabled: true },
      "GQ" => { full_name: "Equatorial Guinea", enabled: true },
      "ER" => { full_name: "Eritrea", enabled: true },
      "EE" => { full_name: "Estonia", enabled: true },
      "ET" => { full_name: "Ethiopia", enabled: true },
      "FK" => { full_name: "Falkland Islands", enabled: true },
      "FO" => { full_name: "Faroe Islands", enabled: true },
      "FJ" => { full_name: "Fiji", enabled: true },
      "FI" => { full_name: "Finland", enabled: true },
      "FR" => { full_name: "France", enabled: true },
      "GF" => { full_name: "French Guiana", enabled: true },
      "PF" => { full_name: "French Polynesia", enabled: true },
      "GA" => { full_name: "Gabon", enabled: true },
      "GM" => { full_name: "Gambia", enabled: true },
      "GE" => { full_name: "Georgia", enabled: true },
      "DE" => { full_name: "Germany", enabled: true },
      "GH" => { full_name: "Ghana", enabled: true },
      "GI" => { full_name: "Gibraltar", enabled: true },
      "GR" => { full_name: "Greece", enabled: true },
      "GL" => { full_name: "Greenland", enabled: true },
      "GD" => { full_name: "Grenada", enabled: true },
      "GP" => { full_name: "Guadeloupe", enabled: true },
      "GU" => { full_name: "Guam", enabled: true },
      "GT" => { full_name: "Guatemala", enabled: true },
      "GG" => { full_name: "Guernsey", enabled: true },
      "GN" => { full_name: "Guinea", enabled: true },
      "GW" => { full_name: "Guinea-Bissau", enabled: true },
      "GY" => { full_name: "Guyana", enabled: true },
      "HT" => { full_name: "Haiti", enabled: true },
      "HN" => { full_name: "Honduras", enabled: true },
      "HK" => { full_name: "Hong Kong", enabled: true },
      "HU" => { full_name: "Hungary", enabled: true },
      "IS" => { full_name: "Iceland", enabled: true },
      "IN" => { full_name: "India", enabled: true },
      "ID" => { full_name: "Indonesia", enabled: true },
      "IR" => { full_name: "Iran", enabled: true },
      "IQ" => { full_name: "Iraq", enabled: true },
      "IE" => { full_name: "Ireland", enabled: true },
      "IM" => { full_name: "Isle of Man", enabled: true },
      "IL" => { full_name: "Israel", enabled: true },
      "IT" => { full_name: "Italy", enabled: true },
      "JM" => { full_name: "Jamaica", enabled: true },
      "JP" => { full_name: "Japan", enabled: true },
      "JE" => { full_name: "Jersey", enabled: true },
      "JO" => { full_name: "Jordan", enabled: true },
      "KZ" => { full_name: "Kazakhstan", enabled: true },
      "KE" => { full_name: "Kenya", enabled: true },
      "KI" => { full_name: "Kiribati", enabled: true },
      "KW" => { full_name: "Kuwait", enabled: true },
      "KG" => { full_name: "Kyrgyzstan", enabled: true },
      "LA" => { full_name: "Laos", enabled: true },
      "LV" => { full_name: "Latvia", enabled: true },
      "LB" => { full_name: "Lebanon", enabled: true },
      "LS" => { full_name: "Lesotho", enabled: true },
      "LR" => { full_name: "Liberia", enabled: true },
      "LY" => { full_name: "Libya", enabled: true },
      "LI" => { full_name: "Liechtenstein", enabled: true },
      "LT" => { full_name: "Lithuania", enabled: true },
      "LU" => { full_name: "Luxembourg", enabled: true },
      "MO" => { full_name: "Macau SAR China", enabled: true },
      "MK" => { full_name: "Macedonia", enabled: true },
      "MG" => { full_name: "Madagascar", enabled: true },
      "MW" => { full_name: "Malawi", enabled: true },
      "MY" => { full_name: "Malaysia", enabled: true },
      "MV" => { full_name: "Maldives", enabled: true },
      "ML" => { full_name: "Mali", enabled: true },
      "MT" => { full_name: "Malta", enabled: true },
      "MH" => { full_name: "Marshall Islands", enabled: true },
      "MQ" => { full_name: "Martinique", enabled: true },
      "MR" => { full_name: "Mauritania", enabled: true },
      "MU" => { full_name: "Mauritius", enabled: true },
      "YT" => { full_name: "Mayotte", enabled: true },
      "MX" => { full_name: "Mexico", enabled: true },
      "FM" => { full_name: "Micronesia", enabled: true },
      "MD" => { full_name: "Moldova", enabled: true },
      "MC" => { full_name: "Monaco", enabled: true },
      "MN" => { full_name: "Mongolia", enabled: true },
      "ME" => { full_name: "Montenegro", enabled: true },
      "MA" => { full_name: "Morocco", enabled: true },
      "MZ" => { full_name: "Mozambique", enabled: true },
      "MM" => { full_name: "Myanmar [Burma]", enabled: true },
      "NA" => { full_name: "Namibia", enabled: true },
      "NR" => { full_name: "Nauru", enabled: true },
      "NP" => { full_name: "Nepal", enabled: true },
      "NL" => { full_name: "Netherlands", enabled: true },
      "NC" => { full_name: "New Caledonia", enabled: true },
      "NZ" => { full_name: "New Zealand", enabled: true },
      "NI" => { full_name: "Nicaragua", enabled: true },
      "NE" => { full_name: "Niger", enabled: true },
      "NG" => { full_name: "Nigeria", enabled: true },
      "NU" => { full_name: "Niue", enabled: true },
      "NF" => { full_name: "Norfolk Island", enabled: true },
      "KP" => { full_name: "North Korea", enabled: true },
      "MP" => { full_name: "Northern Mariana Islands", enabled: true },
      "NO" => { full_name: "Norway", enabled: true },
      "OM" => { full_name: "Oman", enabled: true },
      "PK" => { full_name: "Pakistan", enabled: true },
      "PW" => { full_name: "Palau", enabled: true },
      "PS" => { full_name: "Palestinian Territories", enabled: true },
      "PA" => { full_name: "Panama", enabled: true },
      "PG" => { full_name: "Papua New Guinea", enabled: true },
      "PY" => { full_name: "Paraguay", enabled: true },
      "PE" => { full_name: "Peru", enabled: true },
      "PH" => { full_name: "Philippines", enabled: true },
      "PL" => { full_name: "Poland", enabled: true },
      "PT" => { full_name: "Portugal", enabled: true },
      "PR" => { full_name: "Puerto Rico", enabled: true },
      "QA" => { full_name: "Qatar", enabled: true },
      "RO" => { full_name: "Romania", enabled: true },
      "RU" => { full_name: "Russia", enabled: true },
      "RW" => { full_name: "Rwanda", enabled: true },
      "RE" => { full_name: "Réunion", enabled: true },
      "BL" => { full_name: "Saint Barthélemy", enabled: true },
      "KN" => { full_name: "Saint Kitts and Nevis", enabled: true },
      "LC" => { full_name: "Saint Lucia", enabled: true },
      "MF" => { full_name: "Saint Martin", enabled: true },
      "PM" => { full_name: "Saint Pierre and Miquelon", enabled: true },
      "VC" => { full_name: "Saint Vincent and the Grenadines", enabled: true },
      "WS" => { full_name: "Samoa", enabled: true },
      "SM" => { full_name: "San Marino", enabled: true },
      "SA" => { full_name: "Saudi Arabia", enabled: true },
      "SN" => { full_name: "Senegal", enabled: true },
      "RS" => { full_name: "Serbia", enabled: true },
      "SC" => { full_name: "Seychelles", enabled: true },
      "SL" => { full_name: "Sierra Leone", enabled: true },
      "SG" => { full_name: "Singapore", enabled: true },
      "SK" => { full_name: "Slovakia", enabled: true },
      "SI" => { full_name: "Slovenia", enabled: true },
      "SB" => { full_name: "Solomon Islands", enabled: true },
      "SO" => { full_name: "Somalia", enabled: true },
      "ZA" => { full_name: "South Africa", enabled: true },
      "KR" => { full_name: "South Korea", enabled: true },
      "ES" => { full_name: "Spain", enabled: true },
      "LK" => { full_name: "Sri Lanka", enabled: true },
      "SD" => { full_name: "Sudan", enabled: true },
      "SR" => { full_name: "Suriname", enabled: true },
      "SZ" => { full_name: "Swaziland", enabled: true },
      "SE" => { full_name: "Sweden", enabled: true },
      "CH" => { full_name: "Switzerland", enabled: true },
      "SY" => { full_name: "Syria", enabled: true },
      "ST" => { full_name: "São Tomé and Príncipe", enabled: true },
      "TW" => { full_name: "Taiwan", enabled: true },
      "TJ" => { full_name: "Tajikistan", enabled: true },
      "TZ" => { full_name: "Tanzania", enabled: true },
      "TH" => { full_name: "Thailand", enabled: true },
      "TL" => { full_name: "Timor-Leste", enabled: true },
      "TG" => { full_name: "Togo", enabled: true },
      "TK" => { full_name: "Tokelau", enabled: true },
      "TO" => { full_name: "Tonga", enabled: true },
      "TT" => { full_name: "Trinidad and Tobago", enabled: true },
      "TN" => { full_name: "Tunisia", enabled: true },
      "TR" => { full_name: "Turkey", enabled: true },
      "TM" => { full_name: "Turkmenistan", enabled: true },
      "TC" => { full_name: "Turks and Caicos Islands", enabled: true },
      "TV" => { full_name: "Tuvalu", enabled: true },
      "UM" => { full_name: "U.S. Minor Outlying Islands", enabled: true },
      "VI" => { full_name: "U.S. Virgin Islands", enabled: true },
      "UG" => { full_name: "Uganda", enabled: true },
      "UA" => { full_name: "Ukraine", enabled: true },
      "AE" => { full_name: "United Arab Emirates", enabled: true },
      "GB" => { full_name: "United Kingdom", enabled: true },
      "UY" => { full_name: "Uruguay", enabled: true },
      "UZ" => { full_name: "Uzbekistan", enabled: true },
      "VU" => { full_name: "Vanuatu", enabled: true },
      "VA" => { full_name: "Vatican City", enabled: true },
      "VE" => { full_name: "Venezuela", enabled: true },
      "VN" => { full_name: "Vietnam", enabled: true },
      "WF" => { full_name: "Wallis and Futuna", enabled: true },
      "YE" => { full_name: "Yemen", enabled: true },
      "ZM" => { full_name: "Zambia", enabled: true },
      "ZW" => { full_name: "Zimbabwe", enabled: true }
    }
  },
  file_integrity:                    {
    malicious_paths:  [],
    suspicious_paths: []
  },
  defender:                          {
    enabled: false,
    "DisableRealTimeMonitoring" => false,
    "DisableBehaviorMonitoring" => false,
    "DisableIOAVProtection" => false,
    "DisableScriptScanning" => false,
    "RealTimeScanDirection" => 0,
    "ScanOnlyIfIdle" => true,
    "DisableEmailScanning" => false,
    "PurgeItemsAfterDelay" => 7, # Number
    "DisableCatchupQuickScan" => false,
    "DisableCatchupFullScan" => true,
    "DisableRemoveableDriveScanning" => false,
    "DisableRestorePoint" => false,
    "DisableScanningMappedNetworkDrivesForFullScan" => true,
    "DisableScanningNetworkFiles" => true,
    "DisableArchiveScanning" => false,
    "AvgCPULoadFactor" => 30, # Slider
    "ScanParameters" => 1, # Select
    "ScheduleDay" => 0, # Select
    "ScheduleTime" => 0, # Time picker, convert to minutes after midnight
    "RandomizeScheduleTaskTimes" => false,

    "DisableBlockAtFirstSeen" => false,
    "SpyNetReporting" => 1, # Select
    "SubmitSamplesConsent" => 3, # Select
    "PUAProtection" => 2, # Select

    "block_email_executable_content" => 0, # Select
    "block_office_child_processes" => 0, # Select
    "block_office_creating_executable_content" => 0, # Select
    "block_office_inject_other_process" => 0, # Select
    "prevent_js_and_vb_launch_exe" => 0, # Select
    "block_execution_of_obfuscated_scripts" => 2, # Select
    "block_macro_code_win32_imports" => 2, # Select
    "block_executables_prevalance" => 0, # Select
    "block_lsass_credential_stealing" => 0, # Select
    "block_process_created_psexec_wmi" => 0, # Select
    "block_untrusted_unsigned_from_usb" => 1, # Select
    "advanced_protection_against_ransomware" => 2, # Select
    "block_office_comms_child_processes" => 0, # Select
    "block_adobe_reader_child_processes" => 0, # Select
    "EnableNetworkProtection" => 0, # Select
    "DisableNotifications" => true,
    "UILockdown" => true,
    "Notification_Suppress" => true,
    "DisableDefenderEnhancedNotifications" => true,
    "EnableControlledFolderAccess" => 0, # Select
    "controlled_folder_allowed_applications": [],
    "block_persistence_through_wmi_event_subscription": 0, # Select

    "unknown_threat_default_action": 2,
    "low_threat_default_action": 2,
    "moderate_threat_default_action": 2,
    "high_threat_default_action": 2,
    "severe_threat_default_action": 1,

    "SignatureUpdateInterval": 1,
    "CheckForSignaturesBeforeRunningScan": true,

    "protected_folders": [],

    "process_exclusions": [],
    "path_exclusions": [],
    "extension_exclusions": [],
    "asr_exclusions": []
  },
  advanced_breach_detection:         {
    low_confidence_results:    false,
    enabled_ttps:              { "T1182" => { "enabled"=>true }, "T1103" => { "enabled"=>true }, "T1131" => { "enabled"=>true }, "T1183" => { "enabled"=>true }, "T1128" => { "enabled"=>true }, "T1013" => { "enabled"=>true }, "T1198" => { "enabled"=>true }, "T1101" => { "enabled"=>true }, "T1088" => { "enabled"=>true }, "T1174" => { "enabled"=>true }, "T1137" => { "enabled"=>true }, "T1116" => { "enabled"=>true }, "T1202" => { "enabled"=>true }, "T1036" => { "enabled"=>false }, "T1085" => { "enabled"=>true }, "T1218" => { "enabled"=>true }, "T1047" => { "enabled"=>true }, "T1216" => { "enabled"=>true }, "T1081" => { "enabled"=>true }, "T1214" => { "enabled"=>true }, "T1076" => { "enabled"=>true }, "T1053" => { "enabled"=>true }, "T1173" => { "enabled"=>true }, "T1158" => { "enabled"=>true }, "T1031" => { "enabled"=>true }, "T1050" => { "enabled"=>true }, "T1060" => { "enabled"=>true }, "T1180" => { "enabled"=>true }, "T1209" => { "enabled"=>true }, "T1004" => { "enabled"=>true }, "T1191" => { "enabled"=>true }, "T1118" => { "enabled"=>true }, "T1170" => { "enabled"=>true }, "T1126" => { "enabled"=>true }, "T1121" => { "enabled"=>true }, "T1003" => { "enabled"=>true }, "T1087" => { "enabled"=>false }, "T1135" => { "enabled"=>false }, "T1136" => { "enabled"=>true }, "T1201" => { "enabled"=>true }, "T1069" => { "enabled"=>false }, "T1057" => { "enabled"=>false }, "T1012" => { "enabled"=>false }, "T1018" => { "enabled"=>false }, "T1082" => { "enabled"=>false }, "T1016" => { "enabled"=>false }, "T1049" => { "enabled"=>false }, "T1077" => { "enabled"=>true }, "T1070" => { "enabled"=>true }, "T1007" => { "enabled"=>false }, "T1124" => { "enabled"=>false }, "T1059" => { "enabled"=>true }, "T1086" => { "enabled"=>true }, "T1035" => { "enabled"=>true }, "T1140" => { "enabled"=>true }, "T1105" => { "enabled"=>true }, "T1107" => { "enabled"=>true }, "T1089" => { "enabled"=>true }, "T1117" => { "enabled"=>true }, "T1028" => { "enabled"=>true }, "T1098" => { "enabled"=>false }, "T1490" => { "enabled"=>true }, "T1033" => { "enabled"=>false }, "T1127" => { "enabled"=>false } },
    macos_enabled_ttps:        { "T1016" => { "enabled"=>false }, "T1018" => { "enabled"=>false }, "T1057" => { "enabled"=>false }, "T1069" => { "enabled"=>false }, "T1082" => { "enabled"=>false }, "T1049" => { "enabled"=>false }, "T1087" => { "enabled"=>false }, "T1135" => { "enabled"=>false }, "T1033" => { "enabled"=>false }, "T1201" => { "enabled"=>true }, "T1146" => { "enabled"=>false }, "T1070" => { "enabled"=>true }, "T1166" => { "enabled"=>false }, "T1113" => { "enabled"=>false }, "T1115" => { "enabled"=>false }, "T1155" => { "enabled"=>false } },
    excluded_cli_commands:     %w[],
    excluded_registry_values:  %w[],
    excluded_parent_processes: %w[%ProgramFiles(x86)%\\Kaseya\\*\\KaUsrTsk.exe]
  },
  suspicious_event:                  {
    macos_check_frequency: 300,
    macos_log_privacy:     true,
    macos_enabled_events:  {
      "watch_logon"    => {
        "event_id" => "watch_logon", enabled: true, "filter" => "foo", "description" => %(User Logon to System)
      },
      "failed_auth"    => {
        "event_id" => "failed_auth", enabled: true, "filter" => "foo", "description" => %(User authentication failure)
      },
      "ssh_connection" => {
        "event_id" => "ssh_connection", enabled: true, "filter" => "foo", "description" => %(SSH Connection established - inbound)
      },
      "sudo_usage"     => {
        "event_id" => "sudo_usage", enabled: true, "filter" => "foo", "description" => %(Priviledge escalation using sudo)
      },
      "watch_logout"   => {
        "event_id" => "watch_logout", enabled: true, "filter" => "foo", "description" => %(User Logout of System)
      }
    },
    enabled_events:        {
      "104"   => {
        "event_id" => 104, enabled: true, "log_name" => "System", "description" => %(Security Log was cleared)
      },
      "1100"  => {
        "event_id" => 1100, enabled: true, "log_name" => "System", "description" => %(Event logging was shut down)
      },
      "1102"  => {
        "event_id" => 1102, enabled: true, "log_name" => "Security", "description" => %(Audit log was cleared)
      },
      "4720"  => {
        "event_id" => 4720, enabled: true, "log_name" => "Security", "description" => %(A user account was created)
      },
      "4722"  => {
        "event_id" => 4722, enabled: true, "log_name" => "Security", "description" => %(A user account was enabled)
      },
      "4724"  => {
        "event_id" => 4724, enabled: true, "log_name" => "Security", "description" => %(An attempt was made to reset an accounts password)
      },
      "4735"  => {
        "event_id" => 4735, enabled: true, "log_name" => "Security", "description" => %(Local Group Changed)
      },
      "4738"  => {
        "event_id" => 4738, enabled: true, "log_name" => "Security", "description" => %(User account password changed)
      },
      "7040"  => {
        "event_id" => 7040, enabled: true, "log_name" => "System", "description" => %(The start type of service was changed from auto to disabled)
      },
      "7031"  => {
        "event_id" => 7031, enabled: true, "log_name" => "System", "description" => %(Service terminated unexpectedly. Corrective action will be taken.)
      },
      "7034"  => {
        "event_id" => 7034, enabled: true, "log_name" => "System", "description" => %(Service terminated unexpectedly.)
      },
      "4698"  => {
        "event_id" => 4698, enabled: true, "log_name" => "Security", "description" => %(A new scheduled task was created.)
      },
      "4702"  => {
        "event_id" => 4702, enabled: true, "log_name" => "Security", "description" => %(A scheduled task was modified.)
      },
      "4740"  => {
        "event_id" => 4740, enabled: true, "log_name" => "Security", "description" => %(A user account was locked out.)
      },
      "5142"  => {
        "event_id" => 5142, enabled: true, "log_name" => "Security", "description" => %(A network share object was added.)
      },
      "5143"  => {
        "event_id" => 5143, enabled: true, "log_name" => "Security", "description" => %(A network share object was modified.)
      },
      "5144"  => {
        "event_id" => 5144, enabled: true, "log_name" => "Security", "description" => %(A network share object was deleted.)
      },
      "64004" => {
        "event_id" => 64004, enabled: true, "log_name" => "System", "description" => %(Windows File Protection was unable to restore file to its original valid version.)
      },
      "4625"  => {
        "event_id" => 4625, enabled: true, "log_name" => "Security", "description" => %(An account failed to logon.)
      },
      "4649"  => {
        "event_id" => 4649, enabled: true, "log_name" => "Security", "description" => %(A replay attack was detected.)
      },
      "7036"  => {
        "event_id" => 7036, enabled: true, "log_name" => "System", "description" => %(A defensive service was stopped.),
        "conditions" => {
          "pattern"   => %((Windows Defender|Windows Firewall|Symantec|McAfee|AVG|Panda|Kaspersky|Avast|Avira|BitDefender|ClamAV|Comodo|CrowdStrike|EndGame|FProt|FSecure|Sophos|Fortinet|MalwareBytes|Cylance|TotalDefense|VIPRE|Webroot|Palo Alto Networks).+(stopped)),
          "threshold" => 1
        }
      },
      "5145"  => {
        "event_id" => 5145, enabled: true, "log_name" => "Security", "description" => %(A network share object was checked by PsExec to see whether client can be granted desired access.),
        "conditions" => {
          "pattern"   => %(Share Name:\s+\\\\\*\\IPC\$|PSEXESVC-),
          "threshold" => 2
        }
      }
    }
  },
  suspicious_network_services:       {
    enabled_services:   {
      "0"  => {
        ports:        [19],
        protocol:     "*",
        direction:    "*",
        description:  %(The chargen service is commonly used in denial-of-service attacks),
        service_name: %(Chargen),
        enabled:      true
      },
      "1"  => {
        ports:        [21],
        protocol:     "tcp",
        direction:    "outbound",
        description:  %(FTP is an unencrypted file transfer service vulnerable to sniffing and man in the middle attacks.),
        service_name: %(FTP),
        enabled:      true
      },
      "2"  => {
        ports:        [23],
        protocol:     "tcp",
        direction:    "*",
        description:  %(Telnet is an insecure service that sends data unmasked in clear text),
        service_name: %(Telnet),
        enabled:      true
      },
      "3"  => {
        ports:        [25],
        protocol:     "*",
        direction:    "inbound",
        description:  %(SMTP is an insecure mail service. This service is listening for open connections which could be indicative of a botnet or other spam sending malware.),
        service_name: %(SMTP),
        enabled:      true
      },
      "4"  => {
        ports:        [79],
        protocol:     "*",
        direction:    "*",
        description:  %(Finger service provides attackers host information),
        service_name: %(Finger),
        enabled:      true
      },
      "5"  => {
        ports:        [109, 110],
        protocol:     "*",
        direction:    "inbound",
        description:  %(POP3 is an insecure email service vulnerable to attack. This service is listening for open connections which could be indicative of a botnet or other spam sending malware.),
        service_name: %(POP3),
        enabled:      true
      },
      "6"  => {
        ports:        [666],
        protocol:     "*",
        direction:    "outbound",
        description:  %(DOOM is an online gaming service and very common for backdoor trojans.),
        service_name: %(DOOM),
        enabled:      true
      },
      "7"  => {
        ports:        [1080],
        protocol:     "*",
        direction:    "outbound",
        description:  %(SOCKS is a proxy service vulnerable to viruses, worms and denial of service attacks.),
        service_name: %(SOCKS),
        enabled:      true
      },
      "8"  => {
        ports:        [5900],
        protocol:     "*",
        direction:    "*",
        description:  %(VNC is an insecure remote desktop service vulnerable to numerous attacks. Consider running VNC over SSH if needed.),
        service_name: %(VNC),
        enabled:      true
      },
      "9"  => {
        ports:        [6112],
        protocol:     "*",
        direction:    "outbound",
        description:  %(Battle.net is an online gaming service and very common for backdoor trojans.),
        service_name: %(Battle.net),
        enabled:      true
      },
      "10" => {
        ports:        [6660, 6661, 6662, 6663, 6664, 6665, 6666, 6667, 6668, 6669],
        protocol:     "*",
        direction:    "outbound",
        description:  %(Internet Relay Chat is a common C&C channel for malware and botnets.),
        service_name: %(IRC),
        enabled:      true
      },
      "11" => {
        ports:        [6881, 6882, 6883, 6884, 6885, 6886, 6887, 6888, 6889],
        protocol:     "*",
        direction:    "outbound",
        description:  %(Bit Torrent P2P - File sharing service very popular for malware.),
        service_name: %(Bit Torrent),
        enabled:      true

      },
      "13" => {
        ports:        [9001, 9030, 9050, 9051],
        protocol:     "*",
        direction:    "outbound",
        description:  %(Tor - Suspicious activity dark web browsing and exposes business to botnets and DDoS attacks.),
        service_name: %(Tor),
        enabled:      true
      },
      "16" => {
        ports:        [12345],
        protocol:     "*",
        direction:    "outbound",
        description:  %(NetBus - remote access risk and frequent channel for trojan horses.),
        service_name: %(NetBus),
        enabled:      true
      },
      "19" => {
        ports:        [31337],
        protocol:     "*",
        direction:    "outbound",
        description:  %(Back Orifice - "Elite" service channel for attackers establishing unwanted backdoors.),
        service_name: %(Elite BO),
        enabled:      true
      },
      "20" => {
        ports:        [3389],
        protocol:     "*",
        direction:    "*",
        description:  %(RDP is the Remote Desktop Sharing Protocol.),
        service_name: %(RDP),
        enabled:      true
      },
      "21" => {
        ports:        [22],
        protocol:     "*",
        direction:    "*",
        description:  %(SSH/SFTP is a remote access and secure file transfer protocol.),
        service_name: %(SSH/SFTP),
        enabled:      true
      }
    },
    excluded_ips:       %w[239.225.225.250 224.0.0.252 224.0.0.251],
    process_exclusions: []

  },
  malicious_file_detection:          {
    detect_ransomware_artifacts: false,
    enable_machine_learning:     false,
    excluded_paths:              [],
    excluded_hashes:             %w[
      1c2e2125180b5c0a45afc61870e3b528
    ]
  },
  suspicious_tools:                  {
    enabled_installer_signatures: {
      "aircrack"           => {
        "pattern"     => ["aircrack"],
        "description" => "Aircrack Wireless Sniffer",
        "category"    => "Packet Sniffing Tools",
        enabled: true
      },
      "l0phtcrack"         => {
        "pattern"     => ["l0phtcrack"],
        "description" => "L0phtCrack Password Cracker ",
        "category"    => "Password Cracking Tools",
        enabled: true
      },
      "bfgminer"           => {
        "pattern"     => ["bfgminer"],
        "description" => "BFGminer Bitcoin Mining",
        "category"    => "Crypto Currency Tools",
        enabled: true
      },
      "bitcoin_miner"      => {
        "pattern"     => ["bitcoin"],
        "description" => "Bitcoin Mining",
        "category"    => "Crypto Currency Tools",
        enabled: true
      },
      "easyminer"          => {
        "pattern"     => ["easyminer "],
        "description" => "EasyMiner Bitcoin Mining",
        "category"    => "Crypto Currency Tools",
        enabled: true
      },
      "ethereum"           => {
        "pattern"     => ["ethereum"],
        "description" => "Ethereum Blockchain Network",
        "category"    => "Blockchain Network",
        enabled: true
      },
      "freenet"            => {
        "pattern"     => ["freenet"],
        "description" => "Freenet Browser",
        "category"    => "Darknet Utility",
        enabled: true
      },
      "hashcat"            => {
        "pattern"     => ["hashcat"],
        "description" => "Hashcat Password Recovery",
        "category"    => "Password Cracking Tools",
        enabled: true
      },
      "i2p"                => {
        "pattern"     => ["i2p"],
        "description" => "I2P Browser",
        "category"    => "Darknet Utility",
        enabled: true
      },
      "inSSIDer"           => {
        "pattern"     => ["inSSIDer"],
        "description" => "inSSIDer Wireless Scanner",
        "category"    => "Packet Sniffing Tools",
        enabled: true
      },
      "minergate"          => {
        "pattern"     => %w[minergate xfast],
        "description" => "Minergate Bitcoin Mining",
        "category"    => "Crypto Currency Tools",
        enabled: true
      },
      "nmap"               => {
        "pattern"     => ["Nmap "],
        "description" => "NMap network discovery tool",
        "category"    => "Network discovery",
        enabled: true
      },
      "maltego"            => {
        "pattern"     => ["Maltego"],
        "description" => "Maltego Data Miner",
        "category"    => "Social Engineering Tools",
        enabled: true
      },
      "metasploit"         => {
        "pattern"     => ["Metasploit "],
        "description" => "MetaSploit Exploit Toolkit",
        "category"    => "Exploit Tools",
        enabled: true
      },
      "wireshark"          => {
        "pattern"     => ["Wireshark"],
        "description" => "Wireshark Protocol Analyzer",
        "category"    => "Packing Sniffing Tools",
        enabled: true
      },
      "cain_able"          => {
        "pattern"     => ["Cain & Abel"],
        "description" => "Cain & Abel Password Cracker",
        "category"    => "Password Cracking Tools",
        enabled: true
      },
      "qtorrent"           => {
        "pattern"     => ["qtorrent"],
        "description" => "qBittorent",
        "category"    => "Torrent Utility",
        enabled: true
      },
      "vnc_connect"        => {
        "pattern"     => ["VNC-Server"],
        "description" => "VNC Server remote access tool",
        "category"    => "Remote Access & Control",
        enabled: true
      },
      "open_vpn"           => {
        "pattern"     => ["openvpn"],
        "description" => "OpenVPN",
        "category"    => "Remote Access & Control",
        enabled: true
      },
      "spy_agent"          => {
        "pattern"     => ["SpyAgent"],
        "description" => "SpyAgent Stealth Monitoring",
        "category"    => "Remote Access & Control",
        enabled: true
      },
      "spiceworks"         => {
        "pattern"     => ["Spiceworks"],
  "description" => "Spiceworks remote access tool",
  "category"    => "Remote Access & Control",
  enabled: false
      },
      "atera"              => {
        "pattern"     => ["AteraAgent"],
        "description" => "Atera remote access tool",
        "category"    => "Remote Access & Control",
        enabled: false
      },
      "kaseya_vsa"         => {
        "pattern"     => ["Kaseya Agent"],
        "description" => "Kaseya RMM",
        "category"    => "Remote Access & Control",
        enabled: false
      },
      "datto_rmm"          => {
        "pattern"     => ["Datto RMM"],
        "description" => "Datto RMM",
        "category"    => "Remote Access & Control",
        enabled: false
      },
      "continuum_rmm"      => {
        "pattern"     => ["ITSPlatform"],
        "description" => "Continuum RMM",
        "category"    => "Remote Access & Control",
        enabled: false
      },
      "syncro_rmm"         => {
        "pattern"     => ["Syncro"],
        "description" => "Syncro RMM",
        "category"    => "Remote Access & Control",
        enabled: false
      },
      "labtech_rmm"        => {
        "pattern"     => ["LabTech"],
        "description" => "LabTech RMM",
        "category"    => "Remote Access & Control",
        enabled: false
      },
      "solarwinds_msp_rmm" => {
        "pattern"     => ["Solarwinds MSP"],
        "description" => "SolarWinds MSP RMM",
        "category"    => "Remote Access & Control",
        enabled: false
      },
      "barracuda_msp_rmm"  => {
        "pattern"     => ["Managed Workplace"],
        "description" => "Barracuda Managed Workplace RMM",
        "category"    => "Remote Access & Control",
        enabled: false
      },
      "logmein"            => {
        "pattern"     => ["LogMeIn"],
        "description" => "LogMeIn Remote Control",
        "category"    => "Remote Access & Control",
        enabled: false
      },
      "screenconnect"      => {
        "pattern"     => ["ScreenConnect"],
        "description" => "ConnectWise Control ScreenConnect",
        "category"    => "Remote Access & Control",
        enabled: false
      }
    },
    enabled_filename_signatures:  {
      "hash_suite"    => {
        "files"       => ["hash_suite_64.exe", "hash_suite_32.exe"],
        "description" => "Hash Suite Password Cracker",
        "category"    => "Password Cracking Tools",
        enabled: true
      },
      "BitTorrent"    => {
        "files"       => ["BitTorrent.exe"],
        "description" => "BitTorrent File Download",
        "category"    => "Torrent Utility",
        enabled: true
      },
      "brutus"        => {
        "files"       => ["BrutusA2.exe"],
        "description" => "Brutus Password Cracker",
        "category"    => "Password Cracking Tools",
        enabled: true
      },
      "burp_suite"    => {
        "files"       => ["burp.jar"],
        "description" => "BurpSuite Web Vulnerability Scanner",
        "category"    => "Web Vulnerability Scanner",
        enabled: true
      },
      "thc_hydra"     => {
        "files"       => ["hydra.exe"],
        "description" => "THC Hydra Password Cracker ",
        "category"    => "Password Cracking Tools",
        enabled: true
      },
      "ophcrack"      => {
        "files"       => ["ophcrack.exe"],
        "description" => "ophcrack Password Cracker ",
        "category"    => "Password Cracking Tools",
        enabled: true
      },
      "china_chopper" => {
        "files"       => ["caidao.exe"],
        "description" => "China Chopper Webshell Client",
        "category"    => "Webshell Malicious Script",
        enabled: true
      },
      "mimikatz"      => {
        "files"       => ["mimikatz.exe", "mimidrv.sys", "mimilib.dll", "mimilove.exe"],
        "description" => "MimiKatz Password Cracker",
        "category"    => "Password Cracking Tools",
        enabled: true
      },
      "powersploit"   => {
        "files"       => ["PowerSploit.psd1", "PowerSploit.psm1"],
        "description" => "PowerSploit Penetration Test Framework",
        "category"    => "Penetration Test Tools",
        enabled: true
      },
      "putty"         => {
        "files"       => ["putty.exe", "pscp.exe", "puttytel.exe", "psftp.exe"],
        "description" => "PuTTY SCP SSH / Telnet Client",
        "category"    => "Data Transfer Tools",
        enabled: true
      },
      "rainbowcrack"  => {
        "files"       => ["rtgen.exe", "rtsort.exe", "rtmerge.exe", "rcrack.exe"],
        "description" => "RainbowCrack Password Cracker",
        "category"    => "Password Cracking Tools",
        enabled: true
      },
      "tor_browser"   => {
        "files"       => ["tor.exe"],
        "description" => "Tor Browser",
        "category"    => "Darknet Utility",
        enabled: true
      },
      "utorrent"      => {
        "files"       => ["uTorrent.exe"],
        "description" => "uTorrent File Download",
        "category"    => "Torrent Utility",
        enabled: true
      },
      "bitminter"     => {
        "files"       => ["bitminter.jar"],
        "description" => "BitMinter Bitcoin Mining Pool",
        "category"    => "Crypto Currency Tools",
        enabled: true
      },
      "netbull"       => {
        "files"       => ["NetBull.exe"],
        "description" => "NetBull Keylogger",
        "category"    => "Keylogger",
        enabled: true
      },
      "spyrix"        => {
        "files"       => ["spm_setup.exe"],
        "description" => "Spyrix Keylogger and Monitor",
        "category"    => "Keylogger",
        enabled: true
      },
      "psexec"        => {
        "files"       => ["psexec.exe", "psexec64.exe"],
        "description" => "PsExec Remote Command Execution Tool",
        "category"    => "Remote Command Execution, Lateral Movement Tools",
        enabled: false
      },
      "gotomypc"      => {
        "files"       => ["g2svc.exe"],
        "description" => "GoToMyPC Remote Tools",
        "category"    => "Remote Access & Control",
        enabled: false
      }
    },
    excluded_paths:               [
      %(%WINDIR%\\LTSvc\\),
      %(%WINDIR%\\Temp\\LTCache),
      %(%PROGRAMFILES(x86)%\\LabTech Client\\),
      %(%PROGRAMFILES%\\LabTech Client\\),
      %(%PROGRAMFILES%\\CentraStage\\),
      %(%PROGRAMFILES(x86)%\\CentraStage\\),
      %(%PROGRAMFILES(x86)%\\VMware\\VMware vCenter Converter Standalone\\),
      %(%PROGRAMFILES(x86)%\\LabTech Client\\Putty\\)
    ],
    excluded_titles:              %w[]
  },
  crypto_mining:                     {
    excluded_ips:              %w[239.225.225.250 224.0.0.252 224.0.0.251],
    enabled_interesting_ports: {
      "0" => {
        "ports"        => [8332, 8333],
        "protocol"     => "*",
        "direction"    => "*",
        "description"  => %(Bitcoin Cryptocurrency - Resource intentsive with significant security risks),
        "service_name" => %(Bitcoin),
        "enabled"      => true
      },
      "1" => {
        "ports"        => [9333],
        "protocol"     => "*",
        "direction"    => "*",
        "description"  => %(Litecoin Cryptocurrency),
        "service_name" => %(Litecoin),
        "enabled"      => true
      },
      "2" => {
        "ports"        => [9999],
        "protocol"     => "*",
        "direction"    => "*",
        "description"  => %(Dash Cryptocurrency),
        "service_name" => %(Dash),
        "enabled"      => true
      },
      "3" => {
        "ports"        => [22556],
        "protocol"     => "*",
        "direction"    => "*",
        "description"  => %(Dogecoin Cryptocurrency),
        "service_name" => %(Dogecoin),
        "enabled"      => true
      },
      "4" => {
        "ports"        => [30303],
        "protocol"     => "*",
        "direction"    => "*",
        "description"  => %(Ethereum Cryptocurrency),
        "service_name" => %(Ethereum),
        "enabled"      => true
      }
    },
    enabled_miner_domains:     %(*://load.jsecoin.com/*
*://coinhive.com
*://coin-hive.com
*://coin-have.com
*://*.coin-hive.com/lib*
*://*.coin-hive.com/proxy*
*://*.coin-hive.com/captcha*
*://*.edgeno.de/*
*://*.reasedoper.pw/*
*://*.mataharirama.xyz/*
*://*.listat.biz/*
*://*.lmodr.biz/*
*://*.jyhfuqoh.info/*
*://*.coinhive.com/lib*
*://*.coinhive.com/proxy*
*://*.coinhive.com/captcha*
*://*.minemytraffic.com/lib*
*://*.crypto-loot.com/lib*
*://*.coin-have.com/c/*
*://*.ppoi.org/lib/*
*://*.coinerra.com/lib/*
*://*.minero.pw/miner.min.js*
*://*.coinblind.com/lib/*
*://*.webmine.cz/miner*
*://*.inwemo.com/inwemo.min.js*
*://*.cloudcoins.co/javascript/*
*://*.coinhive-manager.com/ch-manager.js*
*://*.rocks.io/*
*://*.rocks.io/assets/rocks.min.js*
*://*.papoto.com/lib/*
*://*.coinlab.biz/lib/*
*://*.ad-miner.com/lib/*
*://d3iz6lralvg77g.cloudfront.net/*
*://*.hatevery.info/*
*://*.minr.pw/inject*
*://*.d-ns.ga/*
*://*.ron.si/*
*://*.kjli.fi/*
*://*.pema.cl/*
*://*.nullrefexcep.com/*
*://*.hk.rs/*
*://*.cieh.mx/*
*://185.14.28.10/*
*://185.209.23.219/*
*://*.rove.cl/*
*://*.coinimp.com/scripts/*
*://*.statistic.date/*
*://*.static-cnt.bid/*
*://*.hallaert.online/*
*://*.g-content.bid/*
*://harvest.surge.sh/h.js*
*://*.cryptonoter.com/processor.js*
*://*.monerise.com/core/*
*://*.sparechange.io/static/sparechange.js*
*://*.clod.pw/*
*://*.jquery-uim.download/*
*://*.livelyoffers.club/*
*://*.browsermine.com/*
*://*.lightminer.co/*
*://*.xmrm.pw/*
*://*.bmnr.pw/*
*://52.80.10.9/*
*://*.webassembly.stream/*
*://*.cryptoloot.pro/lib*
*://*.kickass.cd/power2/*
*://*.monerominer.rocks/miner*
*://*.monerominer.rocks/scripts/*
*://*.webmine.pro/lib/*
*://*.freecontent.bid/*
*://*.cookiescript.info/libs/*
*://*.monkeyminer.net/deepMiner.js*
*://*.cpu2cash.link/*
*://*.coinpirate.cf/*
*://*.gridcash.net/api/*
*://*.ogrid.org/*
*://*.nathetsof.com/*
*://*.insdrbot.com/*
*://*.l33tsite.info/*
*://*.myadstats.com/*
*://*.yuyyio.com/*
*://*.ajplugins.com/*
*://*.analytics.blue/*
*://*.cfcdist.gdn/*
*://cfceu.duckdns.org/*
*://*.ledhenone.com/*
*://*.crypto-webminer.com/*
*://*.cpufan.club/*
*://*.cryptobara.com/*
*://*.webminepool.com/lib/*
*://*.webminepool.com/captcha/*
*://*.minero.cc/lib/*
*://*.coinrail.io/lib/*
*://*.marcycoin.org/captcha/*
*://*.coin-service.com/*
*://gustaver.ddns.net/*
*://cryptown.netlify.com/*
*://*.msg-2.me/*
*://*.whathyx.com/*
*://*.ewtuyytdf45.com/*
*://*.mutuza.win/*
*://*.vzhjnorkudcxbiy.com/*
*://*.hashing.win/*
*://*.cfcnet.gdn/*
*://cfcs1.duckdns.org/*
*://greenindex.dynamic-dns.net/*
*://*.freecontent.stream/*
*://worker.salon.com/jobs.js*
*://*.cfcnet.top/*
*://*.graftpool.ovh/*
*://refresh-js.bitbucket.io/*
*://fresh-js.bitbucket.io/*
*://*.staticsfs.host/*
*://*.cdn-code.host/*
*://*.bmst.pw/*
*://*.digxmr.com/*
*://*.andlache.com/*
*://*.berateveng.ru/*
*://*.bewaslac.com/*
*://*.biberukalap.com/*
*://*.bowithow.com/*
*://*.butcalve.com/*
*://*.didnkinrab.com/*
*://*.evengparme.com/*
*://*.fatisin.ru/*
*://*.gridiogrid.com/*
*://*.hatcalter.com/*
*://*.hegrinhar.com/*
*://*.hjnbvg.ru/*
*://*.ingorob.com/*
*://*.kedtise.com/*
*://*.ledinund.com/*
*://*.losital.ru/*
*://*.mebablo.com/*
*://*.moonsade.com/*
*://*.nebabrop.com/*
*://*.ningtoldrop.ru/*
*://*.norespar.ru/*
*://*.pearno.com/*
*://*.refunevent.com/*
*://*.rencohep.com/*
*://*.renhertfo.com/*
*://*.retadint.com/*
*://*.rineventrec.com/*
*://*.rintindown.com/*
*://*.rintinwa.com/*
*://*.rowherthat.ru/*
*://*.terethat.ru/*
*://*.thatresha.com/*
*://*.thathislitt.ru/*
*://*.toftofcal.com/*
*://*.veritrol.com/*
*://*.verresof.com/*
*://*.wildianing.ru/*
*://*.witthethim.com/*
*://*.wronpeci.com/*
*://*.wqgkainysj.ru/*
*://*.kalipasindra.online/*
*://*.never.ovh/*
*://*.nexttime.ovh/*
*://webwidgetz.duckdns.org/*
*://cfcd.duckdns.org/*
*://*.tulip18.com/*
*://*.cfcdist.loan/*
*://*.traffic-optical-service.info/*
*://*.silimbompom.com/*
*://*.bablace.com/*
*://*.unrummaged.com/*
*://*.realnetwrk.com/*
*://*.tgtvbngp.ru/*
*://*.okexysylgzo.ru/*
*://*.etzbnfuigipwvs.ru/*
*://*.dzizsih.ru/*
*://*.nddmcconmqsy.ru/*
*://*.altavista.ovh/*
*://*.synconnector.com/*
*://*.0x1f4b0.com/*
*://*.1q2w3.website/*
*://cdn.nablabee.com/*
*://miner.nablabee.com/*
*://*.oinkinns.tk/*
*://*.adrenali.gq/*
*://cdn.adless.io/*
*://*.stati.bid/*
*://*.minescripts.info/*
*://*.aalbbh84.info/*
*://*.bhzejltg.info/*
*://*.pzoifaum.info/*
*://*.ajcryptominer.com/*
*://*.datasecu.download/*
*://*.jquery-cdn.download/*
*://*.traffic-service.info/*
*://*.hhb123.tk/*
*://*.mepirtedic.com/*
*://*.appelamule.com/*
*://*.ulnawoyyzbljc.ru/*
*://may-js.github.io/*
*://*.traffic-info-service.info/*
*://*.traffic-tech-service.info/*
*://*.traffic-gate-service.info/*
*://*.cryptaloot.pro/*
*://*.averoconnector.com/*
*://*.scaleway.ovh/*
*://bauersagtnein.myeffect.net/*
*://carry.myeffect.net/*
*://red-js.github.io/*
*://*.jqcdn.download/*
*://*.freecontent.date/*
*://*.ablen02.tk/*
*://*.ablen07.tk/*
*://*.ablen10.tk/*
*://*.ablen04.tk/*
*://*.ablen09.tk/*
*://*.ablen01.tk/*
*://*.ablen11.tk/*
*://*.ablen06.tk/*
*://*.ablen12.tk/*
*://*.ablen03.tk/*
*://*.ablen08.tk/*
*://*.ablen05.tk/*
*://mxcdn1.now.sh/*
*://mxcdn2.now.sh/*
*://npcdn1.now.sh/*
*://sxcdn02.now.sh/*
*://sxcdn3.now.sh/*
*://sxcdn4.now.sh/*
*://sxcdn6.now.sh/*
*://*.allfontshere.press/*
*://31.187.64.216/*
*://*.freecontent.loan/*
*://*.freecontent.racing/*
*://*.freecontent.win/*
*://*.encoding.ovh/*
*://*.2giga.download/*
*://*.eth-pocket.de/*
*://thelifeisbinary.netlify.com/*
*://thelifeisbinary.ddns.net/*
*://blue-js.github.io/*
*://*.irrrymucwxjl.ru/*
*://*.nerohut.com/srv/*
*://*.gnrdomimplementation.com/*
*://*.ltstyov.ru/*
*://*.pcejuyhjucmkiny.ru/*
*://*.sickrage.ca/js/m.js*
*://*.ksimdw.ru/*
*://*.wrxgandsfcz.ru/*
*://*.jwduahujge.ru/*
*://*.ogondkskyahxa.ru/*
*://*.zavzlen.ru/*
*://*.vzzexalcirfgrf.ru/*
*://black-js.github.io/*
*://*.amhixwqagiz.ru/*
*://*.wmemsnhgldd.ru/*
*://*.hlpidkr.ru/*
*://*.hrfziiddxa.ru/*
*://*.ihdvilappuxpgiv.ru/*
*://*.ivuovhsn.ru/*
*://*.ixvenhgwukn.ru/*
*://*.jqxrrygqnagn.ru/*
*://*.oxwwoeukjispema.ru/*
*://*.svivqrhrh.ru/*
*://*.vpzccwpyilvoyg.ru/*
*://*.wmwmwwfmkvucbln.ru/*
*://*.ziykrgc.ru/*
*://*.mariuspetrescu.gq/*
*://*.hide.ovh/*
*://*.aster18cdn.nl/*
*://*.freshrefresher.com/*
*://*.povw1deo.com/player7/jwpsrve.js*
*://one-jj.github.io/*
*://two-jj.github.io/*
*://three-jj.github.io/*
*://*.uoldid.ru/*
*://*.herphemiste.com/*
*://*.streamdream.ws/a1d7311f2a/*
*://play.video.estream.nu/estream.js*
*://video.streaming.estream.to/player.js*
*://*.fili.cc/assets/libs/mank/webmr.js*
*://*.minercry.pt/*
*://*.streamplay.me/player1/jwplayer.js*
*://*.rmawm7mw.top/*
*://*.basepush.com/*
*://*.arizona-miner.tk/*
*://*.eth-pocket.eu/*
*://*.eth-pocket.com/*
*://*.japveny.ru/*
*://dynya-may.github.io/*
*://*.imhvlhaelvvbrq.ru/*
*://*.vuuwd.com/*
*://*.ethtrader.de/*
*://*.coinwebmining.com/*
*://*.cdn-jquery.host/*
*://*.creadordedinero.com/*
*://*.xvideosharing.site/*
*://*.bezoglasa.online/*
*://*.my-rigs.com/*
*://*.bestcoinsignals.com/*
*://*.xmg.cool/*
*://*.xmr.cool/*
*://*.pazl1.ru/*
*://*.snahome.com/*
*://*.teramill.com/*
*://*.nerdorium.org/*
*://*.eucsoft.com/*
*://*.munero.me/*
*://*.istlandoll.com/*
*://*.2giga.link/toyota*
*://*.ctlrnwbv.ru/*
*://*.ermaseuc.ru/*
*://*.kdmkauchahynhrs.ru/*
*://*.sptlkiyjsglayc.ru/*
*://*.zzqhsrg.ru/*
*://*.zivbxion.ru/*
*://*.bmnadutub.ru/*
*://*.yoaabgvkm.ru/*
*://*.eflbruwqt.ru/*
*://*.wnmyerzbjhu.ru/*
*://*.voumxy.ru/*
*://*.etlrsq.ru/*
*://*.udqgbokvzbnqkf.ru/*
*://*.hbeuwgqt.ru/*
*://*.ybjfsqcevow.ru/*
*://*.wkkjfcgjofbix.ru/*
*://*.lmeeulcfttqv.ru/*
*://*.dxmhkisurxxxhm.ru/*
*://*.afdjljiyagf.ru/*
*://*.igdxzzeglrlqm.ru/*
*://*.xssrmimmnq.ru/*
*://*.kxrcjhogag.ru/*
*://*.fdtpyqqsnzxvt.ru/*
*://*.jhfdmiwcgnty.ru/*
*://*.pertosj.ru/*
*://*.vuryua.ru/*
*://*.jwwhsqz.ru/*
*://*.ftzivuesohvebj.ru/*
*://*.qlzwfzfatjth.ru/*
*://*.qpmsybxqvlje.ru/*
*://*.site.flashx.cc/*
*://*.jqwww.download/*
*://*.jqrcdn.download/*
*://*.proj2018.xyz/*
*://*.jqassets.download/*
*://*.dataservices.download/*
*://*.jqr-cdn.download/*
*://*.jquerrycdn.download/*
*://*.pebx.pl/connect.js*
*://*.ruvuryua.ru/*
*://*.aymcsx.ru/*
*://*.bmcm.pw/*
*://*.bmcm.ml/*
*://*.cloudflane.com/*
*://*.directprimal.com/*
*://*.clgserv.pro/*
*://*.videoplayer2.xyz/*
*://*.upgraderservices.cf/*
*://*.willacrit.com/*
*://*.uzljra.ru/*
*://*.fljgsht.ru/*
*://*.prsrjdr.ru/*
*://*.cdjchpojgifwc.ru/*
*://*.perrege.ru/*
*://*.pampopholf.com/*
*://*.videos.vidto.me/*
*://*.flowplayer.space/*
*://*.on.animeteatr.ru/*
*://*.play.vidzi.tv/*
*://*.play.estream.xyz/*
*://*.js.vidoza.net/*
*://*.belicimo.pw/*
*://*.s01.vidtodo.pro/*
*://*.tainiesonline.pw/*
*://*.mix.kinostuff.com/*
*://*.cc.gofile.io/*
*://*.proxy.multikonline.ru/*
*://*.play.estream.to/*
*://*.scripts.mrpiracy.xyz/*
*://*.yololike.space/*
*://*.d.greece-search.com/*
*://xmr.omine.org/assets/*
*://*.tainiesonline.stream/*
*://*.gay-hotvideo.net/*
*://*.yourloganalytics.com/*
*://*.mytestminer.xyz/*
*://*.s01.vidtod.me/*
*://*.s02.vidtod.me/*
*://*.bajarlo.net/*
*://*.dexim.space/*
*://*.intellecthosting.net/*
*://*.lumanajaska.ml/*
*://*.bjorksta.men/*
*://*.hemnes.win/*
*://*.gitgrub.pro/*
*://*.verifier.live/*
*://*.freecontent.faith/*
*://*.freecontent.party/*
*://*.freecontent.science/*
*://*.freecontent.trade/*
*://*.hostingcloud.accountant/*
*://*.hostingcloud.bid/*
*://*.hostingcloud.date/*
*://*.hostingcloud.download/*
*://*.hostingcloud.faith/*
*://*.hostingcloud.loan/*
*://*.jshosting.bid/*
*://*.jshosting.date/*
*://*.jshosting.download/*
*://*.jshosting.loan/*
*://*.jshosting.party/*
*://*.jshosting.racing/*
*://*.jshosting.review/*
*://*.jshosting.stream/*
*://*.jshosting.trade/*
*://*.jshosting.win/*
*://*.stati.in/*
*://*.cuev.in/*
*://*.play.vb.wearesaudis.net/*
*://*.xgefmxd.ru/*
*://*.minexmr.stream/webmr.js*
*://*.mollnia.com/js/*
*://*.thersprens.com/*
*://*.gramombird.com/*
*://*.sentemanactri.com/*
*://*.ugmfvqsu.ru/*
*://*.auiehechoulh.ru/*
*://*.vtsgaqnfvzcyu.ru/*
*://*.rctfgrazkha.ru/*
*://*.augvtjtnsfnxg.ru/*
*://*.jlzebszkilcz.ru/*
*://*.jqmrqgaunex.ru/*
*://*.jlzebszkilcz.ru/*
*://static.207.35.76.144.clients.your-server.de/*
*://*.lambdafoobar.de/*
*://*.cashbeet.com/*
*://*.serv1swork.com/*
*://*.g1thub.com/*
*://*.f1tbit.com/*
*://*.str1kee.com/*
*://*.hostingcloud.science/*
*://*.reauthenticator.com/*
*://jssdk.beetv.net/*
*://*.swiftmining.win/static/js/base.js*
*://*.swiftmining.win/embed/*
*://*.swiftmining.win/go/*
*://*.moonify.io/moonify.min.js*
*://*.zymerget.bid/*
*://*.alflying.bid/*
*://*.zymerget.faith/*
*://*.flightsy.bid/*
*://*.alflying.date/*
*://*.zymerget.party/*
*://*.flightsy.date/*
*://*.flightzy.date/*
*://*.flightzy.bid/*
*://*.zymerget.date/*
*://*.flightzy.win/*
*://*.flightsy.win/*
*://*.alflying.win/*
*://*.gettate.faith/*
*://*.zymerget.stream/*
*://*.zymerget.win/*
*://*.gettate.racing/*
*://*.gettate.date/*
*://play.vidoza.net/app.js*
*://*.feesocrald.com/*
*://*.soodatmish.com/*
*://jsc.marketgid.com/*
*://*.nabaza.com/*
*://*.drupalupdates.tk/*
*://*.truemine.org/api/*
*://*.nextbdom.ru/*
*://*.verifypow.com/*
*://*.srcip.com/*
*://*.minerad.com/*
*://*.coin-cube.com/*
*://*.service4refresh.info/*
*://*.mi-de-ner-nis3.info/*
*://*.de-mi-nis-ner.info/*
*://*.de-mi-nis-ner2.info/*
*://*.de-nis-ner-mi-5.info/*
*://*.de-ner-mi-nis4.info/*
*://*.money-maker-script.info/*
*://*.money-maker-default.info/*
*://olgakurenkova34.github.io/*
*://drozdovvalerij0.github.io/*
*://*.bitcoin-pay.eu/*
*://*.ethereum-pocket.eu/*
*://*.myregeneaf.com/*
*://*.nexioniect.com/*
*://*.ner-de-mi-nis-6.info/*
*://35.239.57.233/*
*://35.194.26.233/*
*://*.povwideo.cc/player7/jwpsrva.js*
*://*.1q2w3.life/*
*://*.livestatsnet.services/*
*://*.statdynamic.com/*
*://*.ethereum-pocket.de/*
*://spolina472.github.io/*
wss://*.coin-hive.com/proxy*
wss://*.coinhive.com/proxy*
wss://*.crypto-loot.com/proxy*
wss://*.webmine.cz/*
wss://*.minr.pw/*
wss://*.d-ns.ga/*
wss://*.hk.rs/*
wss://*.cieh.mx/*
wss://*.rove.cl/*
wss://*.sparechange.io/*
ws://*.sparechange.io/*
wss://*.webminerpool.com/*
ws://*.webminerpool.com/*
wss://*.xmrm.pw/*
ws://*.xmrm.pw/*
wss://*.bmnr.pw/*
ws://*.bmnr.pw/*
wss://chainblock.science/*
wss://hodling.faith/*
wss://*.cryptoloot.pro/*
wss://*.torrent.pw/*
wss://*.xmrminingproxy.com/*
wss://*.webmine.pro/*
ws://*.webmine.pro/*
wss://*.hodlers.party/*
wss://*.cpu2cash.link/*
wss://*.coinpirate.cf/*
wss://*.ogrid.org/*
wss://*.nathetsof.com/*
wss://*.insdrbot.com/*
wss://*.l33tsite.info/*
wss://*.myadstats.com/*
wss://*.yuyyio.com/*
wss://*.ajplugins.com/*
wss://*.analytics.blue/*
wss://cfceu.duckdns.org/*
wss://*.ledhenone.com/*
ws://*.crypto-webminer.com/*
wss://*.monerise.com/*
wss://*.webminepool.tk/*
wss://*.minero.cc/*
wss://*.coinrail.io/*
wss://*.coin-service.com/*
ws://*.cfcnet.gdn/*
wss://*.cfcnet.gdn/*
ws://cfcs1.duckdns.org/*
wss://cfcs1.duckdns.org/*
wss://greenindex.dynamic-dns.net/*
wss://*.sighash.info/*
wss://*.coiner.site/*
wss://*.zlx.com.br/*
ws://*.cfcnet.top/*
wss://*.cfcnet.top/*
ws://gustaver.ddns.net/*
wss://gustaver.ddns.net/*
wss://*.graftpool.ovh/*
wss://*.staticsfs.host/*
wss://*.cdn-code.host/*
ws://*.bmst.pw/*
wss://*.bmst.pw/*
wss://webwidgetz.duckdns.org/*
wss://nunu-001.now.sh/*
wss://*.unrummaged.com/*
wss://*.realnetwrk.com/*
wss://*.altavista.ovh/*
wss://*.synconnector.com/*
wss://*.estream.to/*
wss://*.0x1f4b0.com/*
wss://*.1q2w3.website/*
wss://*.nablabee.com/*
wss://*.oinkinns.tk/*
wss://*.adrenali.gq/*
wss://*.adless.io/*
wss://*.stati.bid/*
wss://*.minescripts.info/*
wss://*.aalbbh84.info/*
wss://*.bhzejltg.info/*
wss://*.pzoifaum.info/*
wss://*.ajcryptominer.com/*
wss://*.mepirtedic.com/*
wss://*.appelamule.com/*
wss://*.ulnawoyyzbljc.ru/*
wss://*.averoconnector.com/*
wss://*.scaleway.ovh/*
wss://bauersagtnein.myeffect.net/*
wss://carry.myeffect.net/*
wss://open-hive-server-1.pp.ua/*
wss://mxcdn1.now.sh/*
wss://mxcdn2.now.sh/*
wss://npcdn1.now.sh/*
wss://sxcdn02.now.sh/*
wss://sxcdn3.now.sh/*
wss://sxcdn4.now.sh/*
wss://sxcdn6.now.sh/*
ws://*.allfontshere.press/*
ws://31.187.64.216/*
wss://*.freecontent.bid/*
wss://*.freecontent.stream/*
wss://*.freecontent.date/*
wss://*.freecontent.loan/*
wss://*.freecontent.racing/*
wss://*.freecontent.win/*
wss://*.encoding.ovh/*
wss://*.eth-pocket.de/*
wss://thelifeisbinary.ddns.net/*
ws://thelifeisbinary.ddns.net/*
wss://*.irrrymucwxjl.ru/*
wss://*.gnrdomimplementation.com/*
wss://*.ltstyov.ru/*
wss://*.pcejuyhjucmkiny.ru/*
wss://*.sickrage.ca/ch/*
wss://*.adfreetv.ch/*
wss://*.ksimdw.ru/*
wss://*.wrxgandsfcz.ru/*
wss://*.jwduahujge.ru/*
wss://*.ogondkskyahxa.ru/*
wss://*.zavzlen.ru/*
wss://*.vzzexalcirfgrf.ru/*
wss://*.amhixwqagiz.ru/*
wss://*.wmemsnhgldd.ru/*
wss://*.hlpidkr.ru/*
wss://*.hrfziiddxa.ru/*
wss://*.ihdvilappuxpgiv.ru/*
wss://*.ivuovhsn.ru/*
wss://*.ixvenhgwukn.ru/*
wss://*.jqxrrygqnagn.ru/*
wss://*.oxwwoeukjispema.ru/*
wss://*.svivqrhrh.ru/*
wss://*.vpzccwpyilvoyg.ru/*
wss://*.wmwmwwfmkvucbln.ru/*
wss://*.ziykrgc.ru/*
wss://*.hide.ovh/*
wss://*.aster18cdn.nl/*
wss://*.aster18prx.nl/*
wss://*.coinwebmining.com/*
wss://*.nimiqpool.com/*
wss://*.s7ven.com/*
wss://*.mmc.center/*
wss://*.flnqmin.org/*
wss://*.arizona-miner.tk/*
wss://*.nimiq.watch/*
wss://*.laferia.cr/*
wss://*.nimiqtest.net/*
wss://*.uoldid.ru/*
wss://*.imhvlhaelvvbrq.ru/*
wss://*.herphemiste.com/*
wss://*.minercry.pt/*
wss://*.adplusplus.fr/*
wss://*.streamplay.to/*
wss://*.eth-pocket.eu/*
wss://*.eth-pocket.com/*
wss://*.ethtrader.de/*
wss://*.munero.me/*
wss://*.istlandoll.com/*
wss://*.jqwww.download/*
wss://*.jqrcdn.download/*
wss://*.proj2018.xyz/*
wss://*.jqassets.download/*
wss://*.dataservices.download/*
wss://*.jqr-cdn.download/*
wss://*.jquerrycdn.download/*
wss://*.avero.xyz/*
ws://185.193.38.148/*
wss://*.ruvuryua.ru/*
wss://*.cryptaloot.pro/*
wss://*.directprimal.com/*
wss://*.omine.org/*
wss://*.mollnia.com/*
wss://*.thersprens.com/*
wss://*.sentemanactri.com/*
wss://wbmwss.beetv.net/*
wss://*.wmtech.website/*
wss://*.vidoza.net/*
wss://*.f1tbit.com/*
wss://*.soodatmish.com/*
wss://*.marketgid.com/*
wss://*.reauthenticator.com/*
wss://*.ethereum-pocket.eu/*
wss://*.cashbeet.com/*
wss://*.1q2w3.life/*
wss://*.ethereum-pocket.de/*
wss://*.mininghub.club/*),
    excluded_domains:          %(.in-addr.arpa
.rocketcyber.com
wpad.localdomain
.localdomain)
  },
  office365:                         {},
  office365_signin:                  {
    signin_excluded_countries:                     {
      "US" => { full_name: "United States", enabled: true }
    },
    signin_excluded_ips:                           %w[],
    signin_only_report_bad_reputation_connections: false,
    signin_report_all_failed_logins:               false,
    signin_report_only_successful_logins:          false
  },
  powershell_runner:                 {
    enabled_checks:             {
      "Mail Forwarding"                => { "enabled"=>true },
      "Mail Address Spoofing"          => { "enabled"=>false },
      "Mail Statistics"                => { "enabled"=>false },
      "List Unused Accounts (30 days)" => { "enabled"=>false }
    },
    hostname:                   "",
    excluded_mail_destinations: %w[],
    excluded_unused_accounts:   %w[]
  }
}.with_indifferent_access
