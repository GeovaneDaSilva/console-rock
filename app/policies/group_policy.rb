# Authorization for Group objects
class GroupPolicy < ApplicationPolicy
  def show?
    editor?
  end

  def edit?
    editor? && !record.required?
  end

  def update?
    editor?
  end

  def destroy?
    editor? &&
      !record.required? &&
      record.hunts.size.zero?
  end

  def role_accounts
    Account.where("path @> ?", record.account.path)
  end
end
