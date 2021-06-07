module Apps
  # Counter cache for the number of occurrences for an app, for a given verdict,
  # scoped to the account_path, and possibly a device
  class CounterCache < ApplicationRecord
    include Verdictable

    belongs_to :app
    belongs_to :account, foreign_key: :account_path, primary_key: :path

    belongs_to :device, optional: true # Supports both CloudApp and DeviceApp

    scope :with_detections, -> { where("count > ?", 0) }

    def self.sumed_by_path
      Hash[group(:path).sum(:count).sort_by(&:last).reverse]
    end
  end
end
