# Authorization for Customer objects
class CustomerPolicy < AccountPolicy
  def new?
    editor?
  end

  def create?
    editor?
  end

  def make_current?
    viewer?
  end

  def show?
    viewer? || billing?
  end

  def edit?
    editor?
  end

  def update?
    editor?
  end

  def destroy?
    editor?
  end

  def update_customer_settings?
    editor?
  end

  def can_set_customize_logo?
    false
  end

  def edit_notifications?
    editor? && record.nearest_enable_customer_notifications
  end

  def deploy_agents?
    editor?
  end
end
