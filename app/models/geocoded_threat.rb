# Represents a threat location
# Mostly cosmetic
class GeocodedThreat < ApplicationRecord
  belongs_to :account
  belongs_to :threatable, polymorphic: true

  validates :latitude, :longitude, presence: true

  def country
    super.presence&.downcase || "za"
  end
end
