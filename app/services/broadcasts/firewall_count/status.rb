module Broadcasts
  module FirewallCount
    # :nodoc
    class Status < Base
      # include ActionView::Helpers::NumberHelper

      def initialize(account)
        @account = account
        @firewall_counts = account.all_descendant_firewall_counters.group(:count_type).sum(:count)
      end

      def call
        return unless active_channel?(channel_name)

        ActionCable.server.broadcast channel_name, firewall_counts.to_json

        true
      end

      private

      def channel_name
        "firewall_count_#{@account.id}:status"
      end

      def firewall_counts
        {
          received: @firewall_counts["received"],
          parsed:   @firewall_counts["parsed"],
          filtered: @firewall_counts["filtered"],
          reported: @firewall_counts["reported"]
        }
      end
    end
  end
end
