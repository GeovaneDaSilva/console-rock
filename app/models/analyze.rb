# Base class for analysis record
class Analyze < ApplicationRecord
  include AttrJsonable
  self.table_name = "analyses"

  belongs_to :user
  belongs_to :account

  enum status: {
    initialized: 0,
    analyzed:    1,
    submitted:   2,
    abandoned:   3
  }
end
