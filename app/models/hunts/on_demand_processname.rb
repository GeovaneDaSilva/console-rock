module Hunts
  # Helper model for on-demand process name form
  class OnDemandProcessname
    include ActiveModel::Model

    attr_accessor :processname

    validates :processname, presence: true
  end
end
