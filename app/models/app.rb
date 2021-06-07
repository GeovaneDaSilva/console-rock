# :nodoc
class App < ApplicationRecord
  include Flagable

  as_flag :platforms, :windows, :macos
  as_flag :configuration_scopes, :provider, :customer, :device
  as_flag :additional_types, :managed_only

  monetize :price_cents

  belongs_to :upload, optional: true
  belongs_to :display_image, class_name: "Upload"
  belongs_to :display_image_icon, class_name: "Upload"

  has_many :plan_apps, dependent: :destroy
  has_many :plans, through: :plan_apps

  has_many :logic_rules, dependent: :destroy

  has_many :account_apps, dependent: :destroy
  has_many :accounts, through: :account_apps
  has_many :app_configs, class_name: "Apps::Config", dependent: :destroy
  has_many :app_results, class_name: "Apps::Result", dependent: :destroy
  has_many :device_results, class_name: "Apps::DeviceResult", dependent: :destroy
  has_many :cloud_results, class_name: "Apps::CloudResult", dependent: :destroy

  has_many :counter_caches, class_name: "Apps::CounterCache", dependent: :delete_all

  enum indicator: {
    informational: 0,
    malicious:     100,
    suspicious:    200
  }

  enum report_template: {
    generic:                           0,
    ttp:                               1,
    network_connection:                2,
    cyberterrorist_network_connection: 3,
    event:                             4,
    crypto_mining:                     5,
    defender:                          6,
    secure_score:                      7,
    directory_audit:                   8,
    signin:                            9,
    data_discovery:                    10,
    sentinelone:                       11,
    syslog:                            12,
    webroot:                           13,
    cylance:                           14,
    risk_detection:                    15,
    bitdefender:                       16,
    ironscales:                        17,
    deep_instinct:                     18,
    hibp:                              19,
    dns_filter:                        20,
    sophos_av:                         21,
    passly:                            22,
    sen:                               23,
    ess:                               24,
    cysurance:                         25,
    duo:                               26,
    vulnerability_scanner:             27,
    cisco_umbrella:                    28
  }

  enum configuration_type: {
    cyberterrorist_network_connection: 1,
    suspicious_event:                  2,
    suspicious_network_services:       3,
    suspicious_tools:                  4,
    crypto_mining:                     5,
    advanced_breach_detection:         6,
    secure_now:                        7,
    malicious_file_detection:          8,
    file_integrity:                    9,
    system_process_verifier:           10,
    defender:                          11,
    syslog:                            12,
    office365:                         13,
    data_discovery:                    14,
    powershell_runner:                 15,
    office365_signin:                  16,
    sentinelone:                       17,
    webroot:                           18,
    cylance:                           19,
    bitdefender:                       20,
    ironscales:                        21,
    deep_instinct:                     22,
    hibp:                              23,
    dns_filter:                        24,
    sen:                               25,
    sophos_av:                         26,
    ess:                               27,
    passly:                            28,
    vulnerability_scanner:             29,
    cysurance:                         30,
    duo:                               31,
    cisco_umbrella:                    32
  }, _suffix: :config

  enum author: {
    rocketcyber:       0,
    breach_secure_now: 1
  }

  # validates :discreet, inclusion: { in: [false] }, unless: :free?

  scope :free, -> { where(price_cents: 0) }
  scope :paid, -> { where("price_cents > ?", 0) }
  scope :enabled, -> { where(disabled: false) }
  scope :ga, -> { where.not(discreet: true) }
  scope :discreet, -> { where(disabled: false, discreet: true) }
  scope :unmanaged_only, -> { where.not(additional_types: [:managed_only]) }

  def free?
    price.zero?
  end

  def display_type
    type.split("::")[-1]
  end

  def actions
    APP_ACTIONS.fetch(configuration_type, {})
  end

  def actions?
    actions.present?
  end
end
