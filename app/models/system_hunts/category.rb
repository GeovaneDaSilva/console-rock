module SystemHunts
  # :nodoc
  class Category < ApplicationRecord
    has_many :hunts, dependent: :restrict_with_error
    validates :name, presence: true
  end
end
