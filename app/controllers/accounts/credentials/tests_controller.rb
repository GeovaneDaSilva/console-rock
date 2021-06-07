module Accounts
  module Credentials
    # Account scoped credentials test
    class TestsController < AuthenticatedController
      def create
        authorize current_account, :can_manage_apps?

        args = params.except(:action, :app, :controller)

        response = klass_name.constantize.new(args).call
        render json: response
      end

      private

      def klass_name
        app = params[:app].camelize
        if %w[Connectwise Datto Kaseya Syncro].include?(app)
          "Integrations::#{app}::ConnectionTest"
        else
          "#{app}::Services::ConnectionTest"
        end
      end
    end
  end
end
