# nodoc
class FirewallCounter < ApplicationRecord
  enum firewall_type: {
    meraki:     0,
    fortinet:   1,
    sonicwall:  2,
    sophos:     3,
    watchguard: 4,
    untangle:   5,
    ubiquiti:   6,
    barracuda:  7,
    pfsense:    8,
    cisco:      9,
    sophos_utm: 10,
    zyxel:      11
  }

  enum count_type: {
    received: 0,
    parsed:   1,
    filtered: 2,
    reported: 3
  }
end
