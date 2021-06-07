FIREWALLS = {
  meraki:     {
    "urls"                     => { "full_name" => "Reputation lookup on connecting IPs", "type" => "urls", "verdict" => "suspicious" },
    "ids-alerts"               => { "full_name" => "IDS signature match", "type" => "ids-alerts", "verdict" => "malicious" },
    "rogue_ssid_detected"      => { "full_name" => "Rogue SSID detected", "type" => "rogue_ssid_detected", "verdict" => "malicious" },
    "ssid_spoofing_detected"   => { "full_name" => "SSID spoofing detected", "type" => "ssid_spoofing_detected", "verdict" => "suspicious" },
    "vpn_connectivity_change"  => { "full_name" => "Change in VPN connectivity (Use only if VPN should be disabled)", "type" => "vpn_connectivity_change", "verdict" => "suspicious" },
    "flows"                    => { "full_name" => "IP session initiated", "type" => "urls", "verdict" => "suspicious" },
    "device_packet_flood"      => { "full_name" => "Packet flood detected", "type" => "device_packet_flood", "verdict" => "suspicious" },
    "security_event_files"     => { "full_name" => "Malicious file detected", "type" => "security_event", "subtype" => "files", "verdict" => "suspicious" },
    "security_event_ids_match" => { "full_name" => "IDS event match", "type" => "security_event", "subtype" => "ids_match", "verdict" => "suspicious" },
    "user_login"               => { "full_name" => "Successful user login", "type" => "8021x_auth", "verdict" => "informational" }
  },
  cisco:      {
    "1"  => { "full_name" => "Reputation lookup on connecting IPs", "asaID" => "%ASA-6-302013", "iosID" => "%SEC-6-IPACCESSLOGP", "rvrID" => "%RVR-340-Al", "verdict" => "informational" },
    "2"  => { "full_name" => "TCP NULL flags attack", "asaID" => "%ASA-4-400026", "iosID" => "%IDS-4-TCP_FRAG_NULL_SIG", "rvrID" => "%RVR-4-TCPFRAGNULL", "verdict" => "suspicious" },
    "3"  => { "full_name" => "IP fragment attack", "asaID" => "%ASA-4-400007", "iosID" => "%IDS-4-IPFRAG_ATTACK_SIG", "rvrID" => "%RVR-4-IPFRAG", "verdict" => "suspicious" },
    "4"  => { "full_name" => "IP impossible packet attack", "asaID" => "%ASA-4-400008", "iosID" => "%IDS-4-IP_IMPOSSIBLE_SIG", "rvrID" => "%RVR-4-IPIMPOSSIBLE", "verdict" => "suspicious" },
    "5"  => { "full_name" => "Fragmented ICMP traffic attack", "asaID" => "%ASA-4-400023", "iosID" => "%IDS-4-ICMP_FRAGMENT_SIG", "rvrID" => "%RVR-4-ICMPFRAGSIG", "verdict" => "suspicious" },
    "6"  => { "full_name" => "Large ICMP traffic attack", "asaID" => "%ASA-4-400024", "iosID" => "%IDS-4-ICMP_TOOLARGE_SIG", "rvrID" => "%RVR-4-ICMPTOOLARGE", "verdict" => "suspicious" },
    "7"  => { "full_name" => "Ping of death", "asaID" => "%ASA-4-400025", "iosID" => "%IDS-4-ICMP_PING_OF_DEATH_SIG", "rvrID" => "%RVR-4-ICMPPINGOFDEATH", "verdict" => "suspicious" },
    "8"  => { "full_name" => "TCP SYN+FIN flag attack", "asaID" => "%ASA-4-400027", "iosID" => "%IDS-4-TCP_FRAG_SYN_FIN_SIG", "rvrID" => "%RVR-4-TCPFRAGSYNFIN", "verdict" => "suspicious" },
    "9"  => { "full_name" => "TCP FIN flag attack", "asaID" => "%ASA-4-400028", "iosID" => "%IDS-4-TCP_FIN_ONLY_SIG", "rvrID" => "%RVR-4-TCPFRAGFIN", "verdict" => "suspicious" },
    "10" => { "full_name" => "Proxied RPC request", "asaID" => "%ASA-4-400041", "iosID" => "%IDS-4-RPC_CALLIT_REQUEST", "rvrID" => "%RVR-4-CALLIT", "verdict" => "suspicious" },
    "11" => { "full_name" => "FTP improper port specified", "asaID" => "%ASA-4-400030", "iosID" => "%IDS-4-UNAVAILABLE", "rvrID" => "%RVR-4-UNAVAILABLEPORT", "verdict" => "suspicious" },
    "12" => { "full_name" => "UDP bomb", "asaID" => "%ASA-4-400031", "iosID" => "%IDS-4-UDP_BOMB_SIG", "rvrID" => "%RVR-4-UDPBOMB", "verdict" => "suspicious" },
    "13" => { "full_name" => "UDP Snork attack", "asaID" => "%ASA-4-400032", "iosID" => "%IDS-4-UDP_SNORK_SIG", "rvrID" => "%RVR-4-SNORK", "verdict" => "suspicious" },
    "14" => { "full_name" => "UDP Chargen DoS attack", "asaID" => "%ASA-4-400033", "iosID" => "%IDS-4-UDP_CHARGEN_DOS_SIG", "rvrID" => "%RVR-4-UDPCHARGE", "verdict" => "suspicious" },
    "15" => { "full_name" => "Successful admin login", "asaID" => "%ASA-6-605005", "iosID" => "%SEC_LOGIN-5-LOGIN_SUCCESS", "verdict" => "informational" },
    "16" => { "full_name" => "Failed admin login", "asaID" => "%ASA-6-605004", "iosID" => "%SEC_LOGIN-4-LOGIN_FAILED", "rvrID" => "%RVR-4-LOGINFAILED", "verdict" => "informational" }
  },
  fortinet:   {
    "01" => { "full_name" => "FortiGuard allow events", "type" => "webfilter", "subtype" => "ftgd_allow", "verdict" => "suspicious" },
    "02" => { "full_name" => "ActiveX allow events", "type" => "webfilter", "subtype" => "activex_allow", "verdict" => "suspicious" },
    "03" => { "full_name" => "Intrusion attempts  (App Control)", "type" => "app-ctrl", "verdict" => "suspicious" },
    "04" => { "full_name" => "Intrusion attempts (general)", "type" => "anomaly", "verdict" => "malicious" },
    "05" => { "full_name" => "Antivirus alerts", "type" => "virus", "verdict" => "malicious" },
    "06" => { "full_name" => "Data leaks", "type" => "dlp", "verdict" => "suspicious" },
    "07" => { "full_name" => "IPS detections", "type" => "ips", "verdict" => "malicious" },
    "08" => { "full_name" => "System security audit events", "type" => "event", "subtype" => "securityaudit", "verdict" => "suspicious" },
    "09" => { "full_name" => "Reputation lookup on connecting IPs", "type" => "traffic", "subtype" => "forward", "verdict" => "suspicious" },
    "10" => { "full_name" => "Compliance checks", "type" => "event", "subtype" => "compliancecheck", "verdict" => "suspicious" },
    "11" => { "full_name" => "DNS monitoring", "type" => "dns", "verdict" => "suspicious" },
    "12" => { "full_name" => "FortiGuard block events", "type" => "webfilter", "subtype" => "ftgd_block", "verdict" => "suspicious" },
    "13" => { "full_name" => "FortiGuard error events", "type" => "webfilter", "subtype" => "ftgd_error", "verdict" => "suspicious" },
    "14" => { "full_name" => "Admin login successful", "type" => "event", "subtype" => "system", "action" => "login", "verdict" => "suspicious" },
    "15" => { "full_name" => "SSL VPN tunnel down", "type" => "event", "subtype" => "vpn", "action" => "tunnel-down", "verdict" => "suspicious" },
    "16" => { "full_name" => "SSL VPN tunnel up", "type" => "event", "subtype" => "vpn", "action" => "tunnel-up", "verdict" => "suspicious" },
    "17" => { "full_name" => "SSL VPN statistics", "type" => "event", "subtype" => "vpn", "action" => "tunnel-stats", "verdict" => "suspicious" },
    "18" => { "full_name" => "SSL VPN login fail", "type" => "event", "subtype" => "vpn", "action" => "ssl-login-fail", "verdict" => "suspicious" },
    "19" => { "full_name" => "Authentication logon", "type" => "event", "subtype" => "user", "action" => "auth-logon", "verdict" => "suspicious" },
    "20" => { "full_name" => "Authentication logout", "type" => "event", "subtype" => "user", "action" => "auth-logout", "verdict" => "suspicious" },
    "21" => { "full_name" => "FortiClient connection closed", "type" => "event", "subtype" => "endpoint", "action" => "sslvpn_close", "verdict" => "suspicious" },
    "22" => { "full_name" => "FortiClient connection add", "type" => "event", "subtype" => "endpoint", "action" => "sslvpn_add", "verdict" => "suspicious" }
  },
  sonicwall:  {
    "30"   => { "full_name" => "Admin login failure", "verdict" => "suspicious" },
    "31"   => { "full_name" => "Local user login allowed", "verdict" => "informational" },
    "32"   => { "full_name" => "User login failure", "verdict" => "suspicious" },
    "33"   => { "full_name" => "User credential failure", "verdict" => "suspicious" },
    "35"   => { "full_name" => "Attack suspected", "verdict" => "suspicious" },
    "41"   => { "full_name" => "Dropped unknown protocol", "verdict" => "suspicious" },
    "98"   => { "full_name" => "Reputation lookups on IP connections", "verdict" => "suspicious" },
    "159"  => { "full_name" => "AV Expired", "verdict" => "suspicious" },
    "18"   => { "full_name" => "ActiveX access attempt", "verdict" => "informational" },
    "19"   => { "full_name" => "Java access failure", "verdict" => "informational" },
    "20"   => { "full_name" => "ActiveX/Java archive access failure", "verdict" => "informational" },
    "21"   => { "full_name" => "Blocked cookie", "verdict" => "informational" },
    "22"   => { "full_name" => "Ping of death", "verdict" => "malicious" },
    "23"   => { "full_name" => "IP spoofing", "verdict" => "informational" },
    "25"   => { "full_name" => "SYN flood", "verdict" => "suspicious" },
    "27"   => { "full_name" => "Land attack", "verdict" =>   "suspicious" },
    "70"   => { "full_name" => "IPsec to/from illegal host", "verdict" => "informational" },
    "81"   => { "full_name" => "Smurf attack", "verdict" => "suspicious" },
    "82"   => { "full_name" => "Port scan (low confidence)", "verdict" => "informational" },
    "83"   => { "full_name" => "Port scan (high confidence)", "verdict" => "suspicious" },
    "143"  => { "full_name" => "Attack (general)", "verdict" => "suspicious" },
    "165"  => { "full_name" => "Suspicious email attachment", "verdict" => "informational" },
    "177"  => { "full_name" => "TCP FIN scan", "verdict" => "informational" },
    "178"  => { "full_name" => "TCP XMAS scan", "verdict" =>  "informational" },
    "179"  => { "full_name" => "TCP NULL scan", "verdict" =>  "informational" },
    "180"  => { "full_name" => "IPsec replay attack", "verdict" => "suspicious" },
    "229"  => { "full_name" => "IP spoofing to  Central Gateway", "verdict" => "suspicious" },
    "248"  => { "full_name" => "Malicious email attachment", "verdict" =>  "informational" },
    "267"  => { "full_name" => "TCP XMAS (high confidence)", "verdict" =>  "suspicious" },
    "329"  => { "full_name" => "IP lockout - excessive login failures", "verdict" => "suspicious" },
    "446"  => { "full_name" => "PASV FTP spoofing", "verdict" => "suspicious" },
    "527"  => { "full_name" => "FTP bounce attack (PORT)", "verdict" =>  "suspicious" },
    "528"  => { "full_name" => "FTP bounce attack (PASV)", "verdict" =>  "suspicious" },
    "546"  => { "full_name" => "Rogue access point detection", "verdict" => "informational" },
    "548"  => { "full_name" => "Association  flood  from WLAN station", "verdict" => "informational" },
    "606"  => { "full_name" => "Spank attack (multicast)", "verdict" => "suspicious" },
    "608"  => { "full_name" => "IPS detection (general)", "verdict" => "informational" },
    "609"  => { "full_name" => "IPS prevention (general)", "verdict" => "informational" },
    "789"  => { "full_name" => "IPS high priority detection", "verdict" => "informational" },
    "790"  => { "full_name" => "IPS high priority prevention", "verdict" => "informational" },
    "794"  => { "full_name" => "Anti-spyware prevention", "verdict" => "informational" },
    "795"  => { "full_name" => "Anti-spyware detection", "verdict" => "informational" },
    "809"  => { "full_name" => "Gateway antivirus alert", "verdict" => "informational" },
    "1098" => { "full_name" => "DNS rebind attack", "verdict" => "suspicious" },
    "1200" => { "full_name" => "Suspected botnet initiator blocked", "verdict" => "informational" },
    "1201" => { "full_name" => "Suspected botnet responder blocked", "verdict" => "informational" },
    "1213" => { "full_name" => "UDP flood attack", "verdict" => "suspicious" },
    "1214" => { "full_name" => "ICMP flood attack", "verdict" => "suspicious" },
    "1316" => { "full_name" => "ARP attack", "verdict" => "suspicious" },
    "1363" => { "full_name" => "Wireless flood attack", "verdict" => "suspicious" },
    "1376" => { "full_name" => "Nestea/Teardrop attack", "verdict" => "suspicious" },
    "1378" => { "full_name" => "Possible replay attack", "verdict" => "informational" }
  },
  sophos:     {
    "01" => { "full_name" => "Advanced threat detection", "log_type" => "ATP", "log_subtype" => "Alert", "verdict" => "malicious" },
    "02" => { "full_name" => "Reputation lookup on connecting IPs", "log_type" => "Firewall", "log_subtype" => "Allowed", "verdict" => "suspicious" },
    "03" => { "full_name" => "Suspicious firewall authentications", "log_type" => "Event", "log_subtype" => "Authentication", "verdict" => "suspicious" },
    "04" => { "full_name" => "Data leaks", "log_type" => "Anti-Spam", "log_subtype" => "DLP", "verdict" => "suspicious" },
    "05" => { "full_name" => "Denial of service attack", "log_type" => "Anti-Spam", "log_subtype" => "Dos", "verdict" => "informational" },
    "06" => { "full_name" => "Internal compromise check (low confidence)", "log_type" => "Anti-Spam", "log_subtype" => "Outbound Probable Spam", "verdict" => "suspicious" },
    "07" => { "full_name" => "Internal compromise check (high confidence)", "log_type" => "Anti-Spam", "log_subtype" => "Outbound Spam", "verdict" => "malicious" },
    "08" => { "full_name" => "IPSec alerts", "log_type" => "Event", "log_subtype" => "System", "log_component" => "IPSec", "verdict" => "suspicious" },
    "09" => { "full_name" => "VPN activity check (use if no VPN expected)", "log_type" => "Event", "log_subtype" => "System", "log_component" => "SSL VPN", "verdict" => "malicious" },
    "10" => { "full_name" => "Antivirus detections", "log_type" => "Anti-Virus", "log_subtype" => "Virus", "verdict" => "suspicious" },
    "11" => { "full_name" => "Probably Unwanted Applications (PUAs)", "log_type" => "Anti-virus", "log_subtype" => "PUA", "verdict" => "suspicious" },
    "12" => { "full_name" => "IDS/IPS detections (low confidence)", "log_type" => "IDP", "log_subtype" => "Detect", "log_component" => "Anomaly", "verdict" => "suspicious" },
    "13" => { "full_name" => "IDS/IPS detections (high confidence)", "log_type" => "IDP", "log_subtype" => "Detect", "log_component" => "Signatures", "verdict" => "suspicious" },
    "14" => { "full_name" => "User creation monitor", "log_type" => "Event", "log_subtype" => "Admin", "log_component" => "GUI", "verdict" => "informational" }
  },
  watchguard: {
    "01" => { "full_name" => "Source routing attack", "message_ids" => "3000-0152", "verdict" => "suspicious" },
    "02" => { "full_name" => "SYN flood attack", "message_ids" => "3000-0153 3000-0162", "verdict" => "suspicious" },
    "03" => { "full_name" => "ICMP flood attack", "message_ids" => "3000-0154 3000-0163", "verdict" => "suspicious" },
    "04" => { "full_name" => "IKE flood attack", "message_ids" => "3000-0157 3000-0166", "verdict" => "suspicious" },
    "05" => { "full_name" => "IPSEC flood attack", "message_ids" => "3000-0156 3000-0165", "verdict" => "suspicious" },
    "06" => { "full_name" => "UDP flood attack", "message_ids" => "3000-0155 3000-0164", "verdict" => "suspicious" },
    "07" => { "full_name" => "DDOS attack", "message_ids" => "3000-0161", "verdict" => "suspicious" },
    "08" => { "full_name" => "Port scan", "message_ids" => "3000-0159", "verdict" => "suspicious" },
    "09" => { "full_name" => "IPS Traffic detected", "message_ids" => "3000-0150 1AFF-0025 1BFF-0011 1CFF-000D 1DFF-0010 2AFF-0006 2DFF-0001 21FF-000C", "verdict" => "suspicious" },
    "10" => { "full_name" => "GAV Virus found", "message_ids" => "1AFF-0028 1BFF-000C 1CFF-000E 21FF-000F", "verdict" => "suspicious" },
    "11" => { "full_name" => "APT threat detected", "message_ids" => "1AFF-0034 1BFF-0028 1CFF-0015 21FF-001F", "verdict" => "suspicious" },
    "12" => { "full_name" => "DLP violation found", "message_ids" => "1BFF-0024 1CFF-0011 1AFF-002F", "verdict" => "suspicious" },
    "13" => { "full_name" => "Reputation lookup", "message_ids" => "1AFF-002C 3000-0148 2CFF-0000", "verdict" => "suspicious" },
    "14" => { "full_name" => "IP spoofing", "message_ids" => "3000-0169", "verdict" => "suspicious" },
    "15" => { "full_name" => "ARP spoofing attack", "message_ids" => "3000-012C", "verdict" => "suspicious" },
    "16" => { "full_name" => "IPS feature expired", "message_ids" => "3000-0005", "verdict" => "suspicious" },
    "17" => { "full_name" => "Rogue Access Point detected", "message_ids" => "6100-000C", "verdict" => "suspicious" },
    "18" => { "full_name" => "FTP Bounce Attempt", "message_ids" => "1CFF-0019", "verdict" => "suspicious" },
    "19" => { "full_name" => "Detect VPN use (use only if VPN disabled)", "message_ids" => "2500-0000 1400-0000 020B-0001", "verdict" => "suspicious" },
    "20" => { "full_name" => "Administrator login", "message_ids" => "3E00-0002", "verdict" => "informational" }
  },
  untangle:   {
    "01" => { "full_name" => "Content checks (probably unwanted applications)", "class" => "WebFilterEvent", "category" => "Anonymizer,Child Inappropriate,Spyware & Questionable Software", "verdict" => "suspicious" },
    "02" => { "full_name" => "Content checks (illegal activity)", "class" => "WebFilterEvent", "category" => "Child Abuse Images", "verdict" => "malicious" },
    "03" => { "full_name" => "Content checks (malicious sites)", "class" => "WebFilterEvent", "category" => "Botnet,Compromised,Malware Call-Home,Malware Distribution Point,Phishing/Fraud", "verdict" => "malicious" },
    "04" => { "full_name" => "Content checks (remote access tools)", "class" => "WebFilterEvent", "category" => "Remote Access", "verdict" => "suspicious" },
    "05" => { "full_name" => "Reputation lookup on connecting IPs", "class" => "SessionEvent", "verdict" => "suspicious" },
    "06" => { "full_name" => "Authentication monitoring (high value targets)", "class" => "AdminLoginEvent", "success" => "failed", "verdict" => "malicious" },
    "07" => { "full_name" => "Authentication monitoring (general)", "class" => "LoginEvent", "verdict" => "suspicious" },
    "08" => { "full_name" => "Potential compromise (high confidence)", "class" => "IntrusionPreventionLogEvent", "rid" => "1810,1811,1900,2412,2271", "verdict" => "suspicious" },
    "09" => { "full_name" => "Detect VPN use (only if VPN disabled)", "class" => "OpenVpnEvent TunnelStatusEvent OpenVpnStatusEvent TunnelVpnEvent VirtualUserEvent IpsecVpnEvent TunnelVpnStatusEvent", "verdict" => "malicious" },
    "10" => { "full_name" => "AV detections", "class" => "VirusFtpEvent VirusHttpEvent VirusSmtpEvent", "clean" => false, "verdict" => "suspicious" },
    "11" => { "full_name" => "Potential compromise (low confidence)", "class" => "IntrusionPreventionLogEvent", "category" => "backdoor", "verdict" => "suspicious" },
    "12" => { "full_name" => "Successful admin login", "class" => "AdminLoginEvent", "succeeded" => "true", "verdict" => "informational" }
  },
  barracuda:  {
    "01" => { "full_name" => "Attempted Access not covered by Firewall Rules", "id" => "BLOCKALL", "log_file" => "box_Firewall_Activity", "verdict" => "informational" },
    "02" => { "full_name" => "User quarantined alert", "id" => "5000", "log_file" => "box_Event_eventS", "verdict" => "informational" },
    "03" => { "full_name" => "ATP alert (malicious)", "id" => "5001", "log_file" => "box_Event_eventS", "verdict" => "informational" },
    "04" => { "full_name" => "DNS Sinkhole", "id" => "5004", "log_file" => "box_Event_eventS", "verdict" => "informational" },
    "05" => { "full_name" => "Anti-Virus", "id" => "5005", "log_file" => "box_Event_eventS", "verdict" => "informational" },
    "06" => { "full_name" => "ATP (file block)", "id" => "File", "log_file" => "srv_S1_AV", "verdict" => "informational" },
    "07" => { "full_name" => "System login notice", "id" => "4130", "log_file" => "box_Event_eventS", "verdict" => "informational" }
  },
  ubiquiti:   {
    "01" => { "full_name" => "IP blacklisted (OpenProxies)", "rule" => "ASL_OPENPROXIES_BLOCK", "verdict" => "suspicious" },
    "02" => { "full_name" => "IP blacklisted (OpenBL)", "rule" => "ASL_OPENBL_BLOCK", "verdict" => "suspicious" },
    "03" => { "full_name" => "Emerging threats", "rule" => "ASL_EMERGING_THREATS_BLOCK", "verdict" => "suspicious" },
    "04" => { "full_name" => "Suspicious origin IP", "rule" => "ASL_GEO_BLOCK", "verdict" => "suspicious" },
    "05" => { "full_name" => "IP blacklisted (ASL)", "rule" => "ASL_BLACKLIST_BLOCK", "verdict" => "suspicious" },
    "06" => { "full_name" => "DDOS attack via NTP amplifier", "rule" => "DROP_ASL: NTP_DDOS", "verdict" => "malicious" },
    "07" => { "full_name" => "DDOS attack via DNS amplifier", "rule" => "DROP_ASL: DNS_DDOS", "verdict" => "malicious" },
    "08" => { "full_name" => "HeartBleed attack", "rule" => "DROP_ASL: HEARTBEAT", "verdict" => "malicious" },
    "09" => { "full_name" => "Reputation lookup on connecting IPs", "rule" => "ACTIVITY", "verdict" => "suspicious" }
  },
  pfsense:    {
    "01" => { "full_name" => "Malware", "sig_id" => "105 141 144 146 161 162 163 185 209 212 218 219 220", "verdict" => "suspicious" },
    "02" => { "full_name" => "DoS Attack", "sig_id" => "221 226 228 231 234 237 238 239 240 243 244 245 246 247 248 250", "verdict" => "suspicious" },
    "03" => { "full_name" => "DNS Spoof Attack", "sig_id" => "253 254", "verdict" => "suspicious" },
    "04" => { "full_name" => "Communication from malicious URL", "sig_id" => "17904 21246 21255 21256 21257 21475 22958 22960 24031 24032 24033 26396 26401 26402 26405", "verdict" => "suspicious" },
    "05" => { "full_name" => "Administrator login successful", "sig_id" => "340", "verdict" => "informational" },
    "06" => { "full_name" => "Reputation lookup on connecting IPs", "sig_id" => "0001", "verdict" => "suspicious" }
  },
  juniper:    {
    "01" => { "full_name" => "IDS system event", "event_category" => "RT_IDS", "verdict" => "suspicious" },
    "02" => { "full_name" => "IDS protection event", "event_category" => "RT_IDP", "verdict" => "suspicious" },
    "03" => { "full_name" => "IP reputation monitoring", "event_category" => "RT_FLOW", "verdict" => "suspicious" },
    "04" => { "full_name" => "Telnet login authentication failure", "event_category" => "FWAUTH_TELNET_USER_AUTH_FAIL", "verdict" => "suspicious" },
    "05" => { "full_name" => "FTP login authentication failure", "event_category" => "FWAUTH_FTP_USER_AUTH_FAIL", "verdict" => "suspicious" },
    "06" => { "full_name" => "HTTP user login authentication failure", "event_category" => "FWAUTH_HTTP_USER_AUTH_FAIL", "verdict" => "suspicious" },
    "07" => { "full_name" => "Web user login authentication failure", "event_category" => "FWAUTH_WEBAUTH_FAIL", "verdict" => "suspicious" },
    "08" => { "full_name" => "Admin login", "event_category" => "LOGIN_ROOT", "verdict" => "informational" }
  },
  sophos_utm: {
    "01" => { "full_name" => "Virus or Malware Detection", "id" => "#0056", "sys" => "SecureWeb", "sub" => "http", "verdict" => "suspicious" },
    "02" => { "full_name" => "Potentially Unwanted Application (PUA) blocked", "id" => "#0057", "sys" => "SecureWeb", "sub" => "http", "verdict" => "suspicious" },
    "03" => { "full_name" => "Blocked by URL filter", "id" => "#0060", "sys" => "SecureWeb", "sub" => "http", "verdict" => "suspicious" },
    "04" => { "full_name" => "Attempted connection to forbidden country", "id" => "#0067", "sys" => "SecureWeb", "sub" => "http", "verdict" => "suspicious" },
    "05" => { "full_name" => "Request blocked by Advanced Threat Protection (ATP)", "id" => "#0068", "sys" => "SecureWeb", "sub" => "http", "verdict" => "suspicious" },
    "06" => { "full_name" => "ICMP redirect attack", "id" => "#2009", "sys" => "SecureNet", "sub" => "packetfilter", "verdict" => "suspicious" },
    "07" => { "full_name" => "Intrusion Protection System (IPS) alert", "id" => "#2101", "sys" => "SecureNet", "sub" => "ips", "verdict" => "suspicious" },
    "08" => { "full_name" => "User Login Failure", "id" => "#3006", "sys" => "System", "sub" => "auth", "verdict" => "suspicious" },
    "09" => { "full_name" => "User Login Success", "id" => "#3004", "sys" => "System", "sub" => "auth", "verdict" => "suspicious" },
    "10" => { "full_name" => "IP Reputation", "id" => "#2001", "sys" => "SecureNet", "sub" => "packetfilter", "verdict" => "suspicious" }
  },
  zyxel:      {
    "01" => { "full_name" => "Reputation Lookup on Connecting IPs", "msg" => "Traffic Log", "verdict" => "suspicious" },
    "02" => { "full_name" => "TCP IP Spoofing Attack", "msg" => "ip spoofing - no routing entry TCP", "verdict" => "malicious" },
    "03" => { "full_name" => "UDP IP Spoofing Attack", "msg" => "ip spoofing - no routing entry UDP", "verdict" => "malicious" },
    "04" => { "full_name" => "ICMP Source Quench Attack", "msg" => "ICMP Source Quench ICMP", "verdict" => "malicious" },
    "05" => { "full_name" => "ICMP Time Exceeded Attack", "msg" => "ICMP Time Exceed ICMP", "verdict" => "suspicious" },
    "06" => { "full_name" => "ICMP Destination Unreachable Attack", "msg" => "ICMP Destination Unreachable ICMP", "verdict" => "suspicious" },
    "07" => { "full_name" => "Ping of Death", "msg" => "ping of death. ICMP", "verdict" => "malicious" },
    "08" => { "full_name" => "FTP Blocked Per Management Settings", "msg" => "Remote Management: FTP denied", "verdict" => "suspicious" },
    "09" => { "full_name" => "TELNET Blocked per Management Settings", "msg" => "Remote Management: TELNET denied", "verdict" => "suspicious" },
    "10" => { "full_name" => "HTTP or UPnP Blocker Per Management Settings", "msg" => "Remote Management: HTTP or UPnP denied", "verdict" => "suspicious" },
    "11" => { "full_name" => "WWW Service Blocked Per Management Settings", "msg" => "Remote Management: WWW denied", "verdict" => "suspicious" },
    "12" => { "full_name" => "HTTPS Service Blocked Per Management Settings", "msg" => "Remote Management: HTTPS denied", "verdict" => "suspicious" },
    "13" => { "full_name" => "DNS Service Blocked Per Management Settings", "msg" => "Remote Management: DNS denied", "verdict" => "suspicious" },
    "14" => { "full_name" => "Successful Web Login", "msg" => "Successful WEB login", "verdict" => "suspicious" },
    "15" => { "full_name" => "Successful Telnet Login", "msg" => "TELNET Login Successful", "verdict" => "suspicious" },
    "16" => { "full_name" => "Successful FTP Login", "msg" => "Successful FTP login", "verdict" => "suspicious" }
  },
  mikrotik:   {
    "01" => { "full_name" => "Administator Login", "topic" => "system,info,account", "action" => "admin logged in", "verdict" => "informational" },
    "02" => { "full_name" => "Administrator Logout", "topic" => "system,info,account", "action" => "admin logged out", "verdict" => "informational" },
    "03" => { "full_name" => "Login Failure", "topic" => "system,error,critical", "action" => "login failure", "verdict" => "suspicious" },
    "04" => { "full_name" => "Incoming LAN packets without a valid IP Address", "topic" => "firewall,info", "action" => "LAN_!LAN", "verdict" => "suspicious" },
    "05" => { "full_name" => "Incoming packets from a none public IP Address", "topic" => "firewall,info", "action" => "!public", "verdict" => "suspicious" },
    "06" => { "full_name" => "Incoming packets that are not NAT`ted", "topic" => "firewall,info", "action" => "!NAT", "verdict" => "suspicious" },
    "07" => { "full_name" => "Incoming packets from invalid connections", "topic" => "firewall,info", "action" => "!public_from_LAN", "verdict" => "informational" },
    "08" => { "full_name" => "Incoming packets from none public LAN addresses", "topic" => "firewall,info", "action" => "!public_from_LAN", "verdict" => "informational" },
    "09" => { "full_name" => "All custom rules", "topic" => "firewall,info", "action" => "match all", "verdict" => "informational" }
  }
}.freeze