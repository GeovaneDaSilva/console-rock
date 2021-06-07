module Hunts
  # Helper model for on-demand filehash form
  class OnDemandFilehash
    include ActiveModel::Model

    attr_accessor :filehash

    validates :filehash, presence: true
  end
end
