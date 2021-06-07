# Dynamic groups of devices
# Queries Elasticsearch
class Group < ApplicationRecord
  include Searchable

  belongs_to :account
  has_many :hunts, dependent: :destroy
  has_many :feeds, class_name: "Hunts::Feed", dependent: :destroy

  bitmask :query_fields, as: %i[hostname mac_address ipv4_address id], zero_value: :none

  validates :name, presence: true

  after_commit :queue_hunts, on: %i[create update]

  scope :required, -> { where(required: true) }

  def name_with_account
    "#{name} (#{account.name})"
  end

  def device_query
    ActiveRecord::Base.connection.execute("SELECT set_limit(0.7);")
    query = account.all_descendant_devices
    query = query.joins(:egress_ip) if device_query_options[:egress_ips].present?
    query = query.where(device_query_options)

    query = query.fuzzy_search(device_fuzzy_query_options, false) if fuzzy_queryable?
    query
  end

  def family
    family_version_and_edition.to_s.split[0]
  end

  def version
    family_version_and_edition.to_s.split[1]
  end

  def edition
    family_version_and_edition.to_s.split[2]
  end

  def device_fuzzy_query_options
    return if query_fields.is_a?(Integer)

    Hash[*query_fields.collect { |field| [field, query] }.flatten].reject { |_k, v| v.blank? }
  end

  def device_query_options
    {
      network:      network,
      family:       family,
      version:      version,
      edition:      edition,
      architecture: architecture,
      egress_ips:   { ip: public_ip }.reject { |_k, v| v.blank? }

    }.reject { |_k, v| v.blank? }
  end

  def fuzzy_queryable?
    query.present? && device_fuzzy_query_options.present?
  end

  def text_search_blob
    name
  end

  def auto_complete_description
    name
  end

  def broadcast_changes!
    ServiceRunnerJob.perform_later(
      "DeviceBroadcasts::Group", self, { type: "jobs" }.to_json
    )
  end

  def device_count
    @device_count ||= device_query.size
  end

  private

  def queue_hunts
    return if hunts.none?

    ServiceRunnerJob.set(queue: :utility).perform_later("Hunts::DeviceQueuer", self)
  end
end
