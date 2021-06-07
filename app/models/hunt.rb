# :nodoc
class Hunt < ApplicationRecord
  include Searchable

  belongs_to :group
  belongs_to :feed_result, class_name: "Hunts::FeedResult", optional: true
  belongs_to :system_hunts_category, class_name: "SystemHunts::Category",
                                     optional: true, foreign_key: :category_id,
                                     inverse_of: :hunts

  belongs_to :account_app, optional: true

  has_one :account, through: :group
  has_many :tests, class_name: "Hunts::Test", dependent: :destroy
  has_many :conditions, through: :tests, class_name: "Hunts::Condition"
  has_many :hunt_results, dependent: :destroy
  has_many :queued_hunts, class_name: "Devices::QueuedHunt", dependent: :delete_all
  has_many :lastest_revision_hunt_results, class_name: "HuntResult",
                                           primary_key: :revision_id, foreign_key: :hunt_revision_id
  has_one :feed, through: :feed_result, class_name: "Hunts::Feed"

  validates :name, presence: true
  accepts_nested_attributes_for :tests, allow_destroy: true

  after_commit :queue_hunt_for_device, on: %i[create update]

  scope :feed, -> { where.not(feed_result: nil) }
  scope :manual, -> { where(feed_result: nil) }
  scope :continuous, -> { where(continuous: true) }
  scope :not_continuous, -> { where(continuous: false) }
  scope :one_time, -> { where(continuous: false) }
  scope :enabled, -> { where(disabled: false) }
  scope :disabled, -> { where(disabled: true) }
  scope :system_hunt_feeds, -> { where.not(category_id: nil) }
  scope :on_by_default, -> { where(on_by_default: true) }

  enum matching: {
    all_tests: 0,
    any_test:  1
  }

  enum indicator: {
    informational: 0,
    malicious:     100,
    suspicious:    200
  }

  after_create :set_revision_id
  before_update :update_revision_id

  def system_hunt_feed
    category_id.present?
  end

  alias system_hunt_feed? system_hunt_feed

  def tests_for_revision(requested_revision = nil)
    requested_revision ||= revision
    tests.where(revision: requested_revision)
  end

  def revision_tests(requested_revision = nil, build_missing_tests = false)
    requested_revision ||= revision

    unsaved_tests = tests.proxy_association.target.reject { |t| t.type.blank? } # For failed validations

    requested_revision_tests = tests.where(revision: requested_revision).includes(:conditions).to_a

    requested_revision_tests += unsaved_tests
    requested_revision_tests += build_tests(requested_revision_tests.pluck(:type)) if build_missing_tests
    requested_revision_tests.sort_by(&:type)
  end

  def build_tests(existing_test_types = nil, include_admin_tests = false)
    existing_test_types ||= revision_tests.pluck(:type)

    tests_to_build = Hunts::TEST_TYPES
    tests_to_build -= Hunts::ADMIN_TESTS unless include_admin_tests
    tests_to_build -= existing_test_types

    tests_to_build.collect do |test_type|
      test_type.constantize.new.tap(&:build_conditions)
    end.reject(&:nil?)
  end

  def file_identifier(requested_revision = nil)
    requested_revision ||= revision

    ["hunt", id, requested_revision].join("_")
  end

  def reported_device_count
    @reported_device_count ||= hunt_results.where(revision: revision).select(:device_id).distinct.count
  end

  def reported_positive_device_count
    @reported_positive_device_count ||= hunt_results.where(revision: revision).positive
                                                    .select(:device_id).distinct.count
  end

  def feed?
    feed.present?
  end

  def text_search_blob
    name
  end

  def auto_complete_description
    name
  end

  def test_types
    Hunts::TEST_TYPES_MAP
  end

  private

  def index?
    Rails.application.config.index_models && category_id.blank?
  end

  def update_revision_id
    self.revision_id = [id, revision].join("-")
  end

  def set_revision_id
    update_revision_id
    save
  end

  def queue_hunt_for_device
    return if disabled?
    return unless previous_changes[:revision_id]

    ServiceRunnerJob.set(queue: :utility).perform_later("Hunts::DeviceQueuer", self)
  end
end
