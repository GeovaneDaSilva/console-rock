module Hunts
  # Helper model for on-demand url form
  class OnDemandUrl
    include ActiveModel::Model

    attr_accessor :url

    validates :url, presence: true
  end
end
