# Base class for map betweeen antivirus labels and customers
class AntivirusCustomerMap < ApplicationRecord
  belongs_to :account
  belongs_to :app
end
