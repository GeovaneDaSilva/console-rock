# Authorization for Plan objects
class PlanPolicy < ApplicationPolicy
  def edit?
    user.admin?
  end

  def update?
    edit?
  end

  def line_items?
    record.line_items.any?
  end

  def device_line_items?
    record.line_items.plan_base_device.any?
  end

  def office_365_mailbox_line_items?
    record.line_items.office_365_mailbox.any?
  end

  def firewall_line_items?
    record.line_items.firewall.any?
  end

  def destroy?
    record.charges.none?
  end
  # :nodoc
  class Scope < Scope
    def resolve
      if user.admin_role
        scope.all
      else
        scope.where(published: true)
      end
    end
  end
end
