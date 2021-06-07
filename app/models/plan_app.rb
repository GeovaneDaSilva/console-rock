# Plans which include apps
class PlanApp < ApplicationRecord
  belongs_to :plan
  belongs_to :app

  validates :app_id, uniqueness: { scope: :plan_id }
end
