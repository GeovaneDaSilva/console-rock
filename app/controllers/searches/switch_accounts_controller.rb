module Searches
  # Search UI for finding accounts
  class SwitchAccountsController < AuthenticatedController
    def index
      skip_authorization

      @results = Searcher.new(params[:query], current_user, search_for: %w[Provider Customer])
                         .call
                         .page(0)
                         .per(10)
    end

    private

    def skip_credit_card_required?
      true
    end
  end
end
