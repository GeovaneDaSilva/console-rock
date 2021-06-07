module Hunts
  # A result of a feed update
  class FeedResult < ApplicationRecord
    belongs_to :feed, touch: true
    has_one :hunt
  end
end
