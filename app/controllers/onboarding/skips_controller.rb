module Onboarding
  # :nodoc
  class SkipsController < BaseController
    def create
      authorize(account, :show?)

      account.completed!

      redirect_to root_path
    end
  end
end
