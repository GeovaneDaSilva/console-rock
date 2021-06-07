module ActionDispatch
  module Routing
    # :nodoc
    class Mapper
      protected

      def devise_invitation(mapping, controllers)
        resource :invitation, only:       [:update],
                              path:       mapping.path_names[:invitation],
                              controller: controllers[:invitations] do
          get :edit, path: mapping.path_names[:accept], as: :accept
        end
      end
    end
  end
end
