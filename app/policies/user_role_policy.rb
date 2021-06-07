# Authorization for User Role objects
class UserRolePolicy < ApplicationPolicy
  def new?
    editor?
  end

  def create?
    editor?
  end

  def show?
    editor?
  end

  def edit?
    editor?
  end

  def update?
    editor?
  end

  def destroy?
    editor? && owner_minimum?
  end

  def resend_invitation?
    update? && record.user.current_sign_in_at.to_i < record.created_at.to_i
  end

  private

  def user_role_admin?
    admin? || editor?
  end

  def owner_minimum?
    return true unless record.owner?
    return true unless record.role_was == "owner"

    UserRole.where(account: record.account.self_and_ancestors, role: :owner).count > 1
  end

  def role_accounts
    record.account.self_and_ancestors
  end
end
