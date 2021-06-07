# :nodoc
class HuntResult < ApplicationRecord
  belongs_to :hunt
  belongs_to :latest_revision_hunt, class_name:  "Hunt",
                                    foreign_key: :hunt_revision_id,
                                    primary_key: :revision_id
  belongs_to :device, touch: true
  belongs_to :upload

  has_many :test_results, class_name: "Hunts::TestResult", dependent: :destroy
  has_many :ttps, through: :test_results

  scope :processed, -> { where(processed: true) }
  scope :unprocessed, -> { where(processed: false) }
  scope :archived, -> { where(archived: true) }
  scope :unarchived, -> { where(archived: false) }
  scope :feed, -> { joins(:hunt).where.not(hunts: { feed_result: nil }) }
  scope :malicious, -> { positive.joins(:hunt).where(hunts: { indicator: :malicious }) }
  scope :suspicious, -> { positive.joins(:hunt).where(hunts: { indicator: :suspicious }) }
  scope :informational, -> { positive.joins(:hunt).where(hunts: { indicator: :informational }) }
  scope :manually_run, -> { where(manually_run: true) }
  scope :with_ttps, -> { joins(:test_results).where.not(hunts_test_results: { ttp_id: nil }) }

  # By type
  scope :hashes, -> { joins(hunt: [:tests]).where(hunts: { hunts_tests: { id: Hunts::Test.hashes } }) }
  scope :browser, -> { joins(hunt: [:tests]).where(hunts: { hunts_tests: { id: Hunts::Test.browser } }) }
  scope :event, -> { joins(hunt: [:tests]).where(hunts: { hunts_tests: { id: Hunts::Test.event } }) }
  scope :within_date_month, ->(date) { where(created_at: date.beginning_of_month..date.end_of_month) }

  enum status: {
    success: 0,
    failure: 1,
    error:   2
  }

  enum result: {
    negative: 0,
    positive: 1
  }

  validates :account_path, presence: true

  before_create :set_hunt_revision_id
  after_destroy :trash_upload!

  after_commit on: %i[create destroy] do |hunt_result|
    hunt_result.device.update_counters([prevailing_status]) if positive?
  end

  def prevailing_status
    if success?
      return "malicious" if malicious?
      return "suspicious" if suspicious?
      return "informational" if informational?

      "clear"
    else
      status
    end
  end

  def malicious?
    success? && positive? && hunt.malicious?
  end

  def suspicious?
    success? && positive? && hunt.suspicious?
  end

  def informational?
    success? && positive? && hunt.informational?
  end

  def ttp?
    test_results.ttp.any?
  end

  private

  def set_hunt_revision_id
    self.hunt_revision_id = [hunt_id, revision].join("-")
  end

  def trash_upload!
    upload&.trashed!
  end
end
