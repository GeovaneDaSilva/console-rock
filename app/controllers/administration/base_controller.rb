module Administration
  # Base controller for administration
  class BaseController < AuthenticatedController
    before_action :authorize_administration

    private

    def authorize_administration
      authorize :administration, :show?
    end

    def skip_credit_card_required?
      true
    end
  end
end
