# Authorization for Upload objects
class UploadPolicy < ApplicationPolicy
  def show?
    editor?
  end

  def create?
    editor?
  end

  def update?
    editor?
  end

  def destroy?
    editor?
  end

  private

  def role_accounts
    record.sourceable.self_and_ancestors
  end
end
