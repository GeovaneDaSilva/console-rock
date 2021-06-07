module Onboarding
  # :nodoc
  class CompletesController < BaseController
    def show
      authorize(account, :show?)
    end
  end
end
