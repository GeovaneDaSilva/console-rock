# Publish agent releases
class AgentRelease < ApplicationRecord
  audited

  belongs_to :creator, class_name: "User"

  enum period: {
    thirty_minutes: 1800,
    sixty_minutes:  3600,
    ninety_minutes: 5400,
    two_hours:      7200,
    three_hours:    10_800,
    four_hours:     14_400
  }

  has_many :customers, dependent: :nullify

  before_validation :reject_invalid_agent_release_groups
  before_create :generate_id

  validates :description, presence: true
  validates :agent_release_groups, length: { minimum: 1, message: "has no valid targets" }

  def agent_release_group_names
    Account.agent_release_groups.collect { |k, v| k if agent_release_groups.include?(v) }.compact
  end

  def uploads
    @uploads ||= Upload.where(id: upload_ids)
  end

  def all_targeted_customers
    Customer.where(agent_release_group: agent_release_groups)
            .order(agent_release_group: :desc, id: :asc)
  end

  def all_not_targeted_customers
    Customer.where.not(agent_release_group: agent_release_groups)
            .order(agent_release_group: :desc, id: :asc)
  end

  def total_targeted_customers
    @total_targeted_customers ||= all_targeted_customers.size
  end

  def all_customers_pending_release
    all_targeted_customers.where.not(agent_release_id: id)
  end

  def customers_ready_for_release
    all_targeted_customers.order(agent_release_id: :desc).limit(
      (total_targeted_customers * period_progress).ceil
    )
  end

  def release_progress
    customers.size / [total_targeted_customers.to_f, 1].max
  end

  def period_progress
    [(Time.zone.now - created_at).to_i / period_before_type_cast.to_f, 1.0].min
  end

  def release_all_ready_customers!
    agent_release_groups.each do |release_group|
      self.class.with_advisory_lock("agent-release/#{release_group}", timeout_seconds: 0) do
        most_recent_release_for_group = AgentRelease.order(:created_at)
                                                    .where("agent_release_groups @> '{?}'", release_group)
                                                    .last

        if most_recent_release_for_group == self
          customers_ready_for_release.where(agent_release_group: release_group)
                                     .update_all(agent_release_id: id)
        end
      end
    end
  end

  private

  def generate_id
    return if id.present?

    self.id = Time.zone.now.strftime("%Y%m%dT%H%M%S%L")
  end

  def reject_invalid_agent_release_groups
    agent_release_groups.select! { |group_id| Account.agent_release_groups.values.include?(group_id) }
  end
end
