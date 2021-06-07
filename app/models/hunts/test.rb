module Hunts
  # A test for a hunt
  # STI table
  class Test < ApplicationRecord
    HASH_TESTS = %w[
      Hunts::FileHashTest Hunts::FileNameTest Hunts::ProcessHashTest Hunts::ProcessNameTest
    ].freeze
    EVENT_TESTS = %w[
      Hunts::EventFromSourceTest Hunts::EventInCategoryTest Hunts::EventWithIdTest
      Hunts::EventWithTypeTest
    ].freeze

    belongs_to :hunt, touch: true
    belongs_to :lua_script_upload, class_name: "Upload"

    has_many :conditions, dependent: :destroy
    has_many :test_results, dependent: :destroy

    scope :network, -> { where(type: %w[Hunts::NetworkConnectionTest]) }
    scope :browser, -> { where(type: %w[Hunts::BrowserVisitTest]) }
    scope :hashes, -> { where(type: HASH_TESTS) }
    scope :file, -> { where(type: %w[Hunts::FileHashTest Hunts::FileNameTest]) }
    scope :process, -> { where(type: %w[Hunts::ProcessHashTest Hunts::ProcessNameTest]) }
    scope :user, -> { where(type: %w[Hunts::UserTest]) }
    scope :yara, -> { where(type: %w[Hunts::YaraTest]) }
    scope :registry, -> { where(type: %w[Hunts::RegistryKeyTest]) }
    scope :service, -> { where(type: %w[Hunts::ServiceTest]) }
    scope :driver, -> { where(type: %w[Hunts::DriverFileNameTest Hunts::DriverFileHashTest]) }
    scope :dns, -> { where(type: %w[Hunts::DnsCacheTest]) }
    scope :informational, -> { where(type: %w[Hunts::OtherTest]) }
    scope :event, -> { where(type: EVENT_TESTS) }

    accepts_nested_attributes_for :conditions

    before_validation :set_revision, :remove_conditions
    validates :lua_script_description, presence: true, if: :script_override?
    validates :type, presence: true

    def script_override?
      lua_script_upload_id.present?
    end

    def remove_conditions
      self.conditions = [] if script_override?
    end

    def build_conditions; end

    def set_revision
      self.revision = hunt.revision unless changed_attributes[:revision]
    end
  end
end
