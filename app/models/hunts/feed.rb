module Hunts
  # :nodoc
  class Feed < ApplicationRecord
    REVERSINGLABS_KEYWORD_MAP = {
      malware_apt:        "APT Malware",
      malware_ransomware: "Ransomware",
      malware_exploits:   "Exploits",
      network:            "URLs, Domains, and IP Connections"
    }.with_indifferent_access.freeze

    belongs_to :group
    has_many :feed_results
    has_many :hunts, through: :feed_results
    has_one :account, through: :group

    enum source: {
      cymon:          0,
      alien_vault:    1,
      reversing_labs: 2,
      virus_total:    3,
      system_hunts:   4
    }

    after_commit :disable_hunts, on: :destroy

    validates_associated :group
    validates :group_id, presence: true

    def system_hunts=(values)
      self.keyword = values.reject(&:blank?).join(",")
    end

    def system_hunts
      if persisted?
        Hunt.system_hunt_feeds.where(id: keyword.split(",").reject(&:blank?).collect(&:to_i)).pluck(:id)
      else
        Hunt.system_hunt_feeds.where.not(id: Hunt.system_hunt_feeds.on_by_default).pluck(:id)
      end
    end

    private

    def disable_hunts
      hunts.update_all(disabled: true)
    end
  end
end
