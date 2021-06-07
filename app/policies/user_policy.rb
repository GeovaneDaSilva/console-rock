# Authorization for User objects
class UserPolicy < ApplicationPolicy
  # Any authenticated user should be able to edit their own profile
  def create?
    true
  end

  def show?
    true
  end

  def destroy?
    true
  end

  def fetch_job_status?
    true
  end
end
