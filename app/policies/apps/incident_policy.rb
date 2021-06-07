module Apps
  # Authorization for Apps::Incident objects
  class IncidentPolicy < ApplicationPolicy
    def index?
      viewer?
    end

    def show?
      viewer?
    end

    def edit?
      soc_team?
    end

    def update?
      edit?
    end

    def create?
      omnipotent?
    end

    def destroy?
      soc_team? && record.draft?
    end

    def publish?
      soc_team? && record.draft?
    end

    def notify?
      soc_team? && record.published?
    end

    def resolve?
      incident_responder? && record.published?
    end

    def remediate?
      editor? || customer_remediation
    end

    # :nodoc
    class Scope < Scope
      def resolve
        if user.omnipotent? || user.soc_operator?
          scope
        else
          scope.published_or_resolved
        end
      end
    end

    private

    def customer_remediation
      incident_responder? && record.published? && record.account.managed?
    end

    def role_accounts
      Account.where("path @> ?", record.account_path)
    end
  end
end
