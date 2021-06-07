# Base class for all policies
class ApplicationPolicy
  attr_reader :user, :record
  delegate :admin?, :omnipotent?, :soc_operator?, to: :user

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def viewer?
    %w[omnipotent soc_operator owner incident_responder viewer].include?(role)
  end

  def incident_responder?
    %w[omnipotent soc_operator owner incident_responder].include?(role)
  end

  def editor?
    %w[omnipotent soc_operator owner].include?(role)
  end

  def soc_team?
    %w[omnipotent soc_operator].include?(role)
  end

  def billing?
    %w[omnipotent soc_operator owner billing distributor_billing].include?(role)
  end

  # :nodoc
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  private

  def role
    user&.admin_role || user_role&.role
  end

  def user_role
    @user_role ||= UserRole.where(user: user, account: role_accounts)
                           .order(:role).first
  end

  def role_accounts
    raise NotImplementedError, "Role scope not defined"
  end
end
