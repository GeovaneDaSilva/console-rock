module Plans
  module Hooks
    # :nodoc
    class DisableOffice365Apps < Base
      def call
        enabled_office365_apps.update_all(disabled_at: DateTime.current)
      end

      private

      def enabled_office365_apps
        AccountApp.joins(:app)
                  .where(account: @account.self_and_all_descendants)
                  .where(apps: { configuration_type: office365_configuration_types })
      end

      def office365_configuration_types
        [
          App.configuration_types[:office365],
          App.configuration_types[:office365_signin]
        ]
      end
    end
  end
end
