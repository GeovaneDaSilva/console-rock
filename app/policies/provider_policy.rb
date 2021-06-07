# Authorization for Provider objects
class ProviderPolicy < AccountPolicy
  # TODO: Add tests when logic is built out around this
  def new?
    record.nil? || !record.persisted? || root_provider_owner?
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
    omnipotent?
  end

  def create_sub_providers?
    editor? && !admin?
  end

  def create_customers?
    editor?
  end

  def manage_cysurance?
    editor?
  end

  def update_provider_settings?
    editor?
  end

  def inherits_logo?
    !can_customize_logo? && record.parent_logo || can_customize_logo? && !record.logo && record.parent_logo
  end

  def can_set_customize_logo?
    true
  end

  def can_customize_logo?
    record.setting.can_customize_logo?
  end

  # :nodoc
  class Scope < Scope
    def resolve
      scope.joins(:users).where(users: { id: user.id })
    end
  end

  private

  def root_provider_owner?
    user.admin_role == "omnipotent" ||
      UserRole.where(user: user, account: record.root, role: :owner).exists?
  end
end
