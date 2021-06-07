module Hunts
  # Helper model for on-demand filename form
  class OnDemandFilename
    include ActiveModel::Model

    attr_accessor :filename

    validates :filename, presence: true
  end
end
