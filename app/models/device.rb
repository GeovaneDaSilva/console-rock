# Represents a Device
class Device < ApplicationRecord
  include Searchable
  include CustomCacheKeyable
  include ActionView::Helpers::DateHelper
  include Devices::Klassable

  custom_cache_key :group_attributes_cache_key,
                   %I[hostname ipv4_address mac_address egress_ip_id network customer_id
                      platform family version edition architecture build]

  enum connectivity: {
    offline:  0,
    unknown:  1,
    online:   2,
    isolated: 3
  }

  enum defender_health_status: {
    unknown:   0,
    healthy:   1,
    unhealthy: 2
  }, _prefix: :defender_health_status

  enum device_type: {
    server:          1,
    desktop:         2,
    laptop:          3,
    virtual_machine: 4,
    firewall:        5,
    network:         6,
    mobile:          7,
    others:          8
  }

  belongs_to :customer
  belongs_to :egress_ip, counter_cache: true
  belongs_to :inventory_upload, class_name: "Upload", dependent: :destroy

  has_many :hunt_results, dependent: :destroy
  has_many :latest_revision_completed_hunts, through: :hunt_results, source: :latest_revision_hunt
  has_many :uploads, as: :sourceable
  has_many :agent_logs, class_name: "Devices::AgentLog", dependent: :destroy
  has_many :crash_reports, dependent: :destroy
  has_many :connectivity_logs, class_name: "Devices::ConnectivityLog", dependent: :delete_all
  has_many :remediations, class_name: "RemediationTypes::Device", foreign_key: :target_id,
    dependent: :destroy, inverse_of: :device
  has_many :app_results, -> { where.not(device_id: nil) }, class_name: "Apps::DeviceResult",
                                                           dependent:  :destroy, inverse_of: :device
  has_many :incident_app_results, -> { where(incident: true) }, class_name: "Apps::DeviceResult",
                                                                inverse_of: :device
  has_many :app_configs, class_name: "Apps::DeviceConfig", dependent: :destroy
  has_many :queued_hunts, class_name: "Devices::QueuedHunt", dependent: :delete_all

  has_many :app_counter_caches, class_name: "Apps::CounterCache", dependent: :delete_all

  validates :uuid, presence: true, uniqueness: { scope: :customer_id }
  validates :ipv4_address, :hostname, :account_path, presence: true
  validates :ipv4_address, :ipv4_subnet_mask, format: { with: Resolv::IPv4::Regex }
  validates :timezone, inclusion: { in: TIMEZONENAMES }

  before_validation :determine_network
  before_validation :set_uuid!, on: :create
  after_destroy :trash_uploads
  after_commit :queue_hunts, on: %i[create update]
  after_commit :touch_accounts, on: %i[create destroy]

  scope :not_deleted, -> { where(marked_for_deletion: false) }
  scope :recently_connected, -> { order("connectivity DESC, devices.updated_at DESC") }
  scope :active_within_month, -> { where(updated_at: 1.month.ago..DateTime.current) }
  scope :defender_health_status_not_healthy, -> { where.not(defender_health_status: 1) }
  scope :inactive, -> { where(connectivity: :offline).where("connectivity_updated_at < ?", 30.days.ago) }

  def self.find(id)
    super(id.downcase)
  rescue ActiveRecord::RecordNotFound
    find_by!(uuid: id.downcase)
  end

  def self.searchable_columns
    %i[
      hostname ipv4_address network mac_address platform family version edition architecture
      release build
    ]
  end

  def id=(id)
    super id.downcase
  end

  def os
    [platform, family, version, edition, architecture, release, build].reject(&:blank?).join(" ")
  end

  def family_version_edition
    [family, version, edition].reject(&:blank?).join(" ")
  end

  def platform_family_and_version
    [platform, family, version].join(" ")
  end

  def build
    "(build #{super})" if super.present?
  end

  def release
    "Release #{super}" if super.present?
  end

  def status_text
    if offline?
      [
        connectivity,
        "Last seen: #{time_ago_in_words connectivity_updated_at} ago"
      ].join(", ")
    else
      [
        connectivity,
        "Connected since: #{I18n.localize(last_connected_at.in_time_zone(timezone), format: :digital)}"
      ].join(", ")
    end
  end

  def group_ids
    groups = Group.where(account: customer.root.self_and_all_descendants)
    Rails.cache.fetch(["v3/device-group-ids", customer_id, groups, group_attributes_cache_key, created_at]) do
      return [] if groups.blank?

      groups.collect do |group|
        group.id if group.device_query.where(id: id).any?
      end.reject(&:nil?)
    end
  end

  def hunted_geocoded_threats
    geocoded_threats_table = GeocodedThreat.arel_table
    tests_table = Hunts::Test.arel_table
    hunts_table = Hunt.arel_table

    casts_geocoded_foreign_key = Arel::Nodes::NamedFunction.new(
      "CAST", [geocoded_threats_table[:threatable_id].as("integer")]
    )

    tests_constraints = geocoded_threats_table.create_on(tests_table[:id].eq(casts_geocoded_foreign_key))
    tests_join = geocoded_threats_table.create_join(tests_table, tests_constraints)

    hunts_constraints = tests_table.create_on(hunts_table[:id].eq(tests_table[:hunt_id]))
    hunts_join = tests_table.create_join(hunts_table, hunts_constraints)

    GeocodedThreat.joins(tests_join, hunts_join).where(hunts: { id: latest_revision_completed_hunts })
  end

  def most_recent_hunt_results
    hunt_results.unarchived.joins(:hunt)
                .where(hunts: { id: latest_revision_completed_hunts.distinct })
  end

  def hash_progress
    Rails.cache.read("device-hash-progress/#{id}") || 0.0
  end

  def hash_progress=(val)
    Rails.cache.write("device-hash-progress/#{id}", val)
  end

  def account
    customer
  end

  def text_search_blob
    (%i[
      id hostname ipv4_address network mac_address platform family version
      edition architecture build connectivity
    ].collect { |attr| send(attr) } + [
      os, family_version_edition, egress_ip&.ip, platform_family_and_version
    ]).reject(&:blank?).join(" ")
  end

  def auto_complete_description
    hostname
  end

  def logs
    "Devices::Log".constantize
    @logs ||= Devices::LogRelation.new(self)
  end

  def defender_status
    "Devices::DefenderStatus".constantize
    @defender_status ||= Devices::DefenderStatusRelation.new(self, max_relation_size: 1)
  end

  def app_config_for_app(app)
    app_configs.where(app: app).first ||
      Apps::AccountConfig.joins(:account).where(
        type: "Apps::AccountConfig", account_id: customer.self_and_ancestors.select(:id),
        app: app
      ).order("accounts.path DESC").first
  end

  def update_counters(scopes = %i[malicious suspicious informational])
    return if destroyed?

    attrs_for_update = {}
    scopes.each do |scope|
      case scope.to_sym
      when :malicious
        attrs_for_update[:malicious_count] = (
          hunt_results.unarchived.malicious.count + app_counter_caches.malicious.sum(:count)
        )
      when :suspicious
        attrs_for_update[:suspicious_count] = (
          hunt_results.unarchived.suspicious.count + app_counter_caches.suspicious.sum(:count)
        )
      when :informational
        attrs_for_update[:informational_count] = (
          hunt_results.unarchived.informational.count + app_counter_caches.informational.sum(:count)
        )
      end
    end

    update_columns(attrs_for_update) if attrs_for_update.present?
  end

  def inventory
    return {} if inventory_upload_id.blank?

    @inventory ||= JSON.parse(
      ActiveSupport::Multibyte::Unicode.tidy_bytes(
        Uploads::Downloader.new(inventory_upload).call.read,
        true
      )
    )
  end

  def macos_inventory
    result = {}
    {
      "hardware" => %w[apple_pay bluetooth diagnostics ethernet_cards firewire graphics
                       displays memory nvmexpress power storage thunderbolt usb],
      "network"  => %w[firewall locations volumes wifi],
      "software" => %w[applications developer_tools disabled_software extensions
                       installations langauge_and_region logs startup_items]
    }.each do |k, values|
      result[k] = {} if result[k].nil?
      values.each do |v|
        val = inventory.dig(k, v)
        result[k][v] = inventory.dig(k, v) if val.present?
      end
    end
    result
  end

  private

  def touch_accounts
    return unless customer&.path

    Account.with_advisory_lock("account-touch/#{customer.path.split('.').first}") do
      customer.self_and_ancestors.update_all(updated_at: DateTime.current)
    end
  end

  def set_uuid!
    self.uuid = Digest::MD5.hexdigest([fingerprint, customer.license_key].join("-"))
  end

  def trash_uploads
    uploads.find_each(&:trashed!)
  end

  def determine_network
    self.network = IPAddress("#{ipv4_address}/#{ipv4_subnet_mask}").network.to_string
  end

  def queue_hunts
    return unless previous_changes[:previous_changes]

    ServiceRunnerJob.set(queue: :utility).perform_later("Hunts::DeviceQueuer", self)
  end
end
