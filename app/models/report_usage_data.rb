# nodoc
class ReportUsageData < ApplicationRecord
  belongs_to :account
  belongs_to :plan
end
