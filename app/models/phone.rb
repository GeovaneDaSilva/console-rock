# nodoc
class Phone < ApplicationRecord
  belongs_to :account

  validates :numbers, inclusion: { in: [] }, unless: :valid_numbers?

  enum category: {
    security: 1
  }

  # Since we sell all over the world, really the only check I'm doing for phone number
  # is that it is only numbers and '-'.  Even that may be too restrictive
  def valid_numbers?
    numbers.each do |phone_number|
      return false unless phone_number =~ /\A^[\d\-]+\z/
    end
    true
  end
end
