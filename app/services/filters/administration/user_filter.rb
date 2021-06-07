module Filters
  module Administration
    # Filter down a list of users based on given parameters
    class UserFilter
      def initialize(params)
        @params = params
      end

      def call
        if @params[:search].blank?
          User.all
        else
          User.fuzzy_search(
            { first_name: @params[:search], last_name: @params[:search], email: @params[:search] },
            false
          )
        end
      end

      alias filter call
    end
  end
end
