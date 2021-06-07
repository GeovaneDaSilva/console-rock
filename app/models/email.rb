# nodoc
class Email < ApplicationRecord
  belongs_to :account

  validates :emails, inclusion: { in: [] }, unless: :valid_emails?

  enum category: {
    security: 1,
    billing:  2,
    business: 3
  }

  def valid_emails?
    return false if emails.nil?

    emails.each do |email|
      return false unless email =~ /\A([\w\.-]+)@([\w]+)\.[a-zA-Z]{2,6}\z/
    end
    true
  end
end
