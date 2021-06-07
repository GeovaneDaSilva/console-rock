module Broadcasts
  module Remediations
    # :nodoc
    class Status < Base
      # include ActionView::Helpers::NumberHelper

      def initialize(remediation)
        @remediation = remediation
      end

      def call
        return unless active_channel?(channel_name)

        ActionCable.server.broadcast channel_name, remediation_status.to_json
        # ActionCable.server.broadcast channel_name, @remediation.to_json

        true
      end

      private

      def channel_name
        "remediation_#{@remediation.id}:status"
      end

      def remediation_status
        status_detail = nil
        if @remediation.status == "complete"
          status_detail = @remediation.status_detail
        elsif @remediation.status == "failed"
          status_detail = @remediation.updated_at
        end

        {
          id:            @remediation.id,
          updated_at:    @remediation.updated_at,
          status:        @remediation.status,
          status_detail: status_detail
        }
      end
    end
  end
end
