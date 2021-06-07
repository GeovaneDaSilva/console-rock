module Hunts
  # Condition for a test
  class Condition < ApplicationRecord
    belongs_to :test

    validates :test, presence: true
    validates :condition, format: { without: /(\]\=\])/, allow_blank: true }
    validates :condition, format: { without: /(\]\])/, allow_blank: true }
    validates :condition, format: { without: /(\[\=\[)/, allow_blank: true }
    validates :condition, format: { without: /(\[\[)/, allow_blank: true }

    default_scope -> { order(:order) }

    enum operator: {
      is_equal_to: 0, is_not_equal_to:         1,
      starts_with: 2, does_not_start_with:     3,
      ends_with: 4, does_not_end_with:       5,
      exists: 6, does_not_exist:          7,
      contains: 8, does_not_contain:        9
    }

    def condition_to_sentence
      condition.split(",").to_sentence(last_word_connector: " or ")
    end
  end
end
