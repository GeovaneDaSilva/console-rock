module Broadcasts
  module Accounts
    # :nodoc
    class Template < Base
      VALID_TEMPLATES = %w[
        devices_online devices_offline office_mailboxes firewalls
      ].freeze

      def initialize(account, template)
        @account  = account
        @template = template
      end

      def call
        return unless active_channel?(channel_name)

        ActionCable.server.broadcast channel_name, html

        true
      end

      private

      def template
        @template if Broadcasts::Accounts::Template::VALID_TEMPLATES.include?(@template)
      end

      def channel_name
        "account:#{@account.id}:#{template}"
      end

      def html
        AuthenticatedController.renderer.render(
          partial: "accounts/#{template}", locals: { current_account: @account, loading: false }
        ).squish
      end
    end
  end
end
