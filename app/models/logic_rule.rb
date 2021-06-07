# :nodoc
class LogicRule < ApplicationRecord
  audited

  belongs_to :app
  belongs_to :user, optional: true
  belongs_to :account
end
