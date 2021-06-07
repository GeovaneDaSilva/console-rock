module Apps
  module Results
    # Processor notification
    module ProcessorNotifications
      def notify_subscriptions!
        notify_subscribers_of_event(:malicious_indicator) if @app_result.malicious?
        notify_subscribers_of_event(:suspicious_indicator) if @app_result.suspicious?
      end

      def notify_subscribers_of_event(event)
        device = @app_result.is_a?(Apps::DeviceResult) ? @app_result.device : nil
        account = Account.find(@app_result.customer_id)
        ServiceRunnerJob.perform_later(
          "EventPublisher",
          account, device, event.to_s, message: {
            txt: txt_notification_payload, html: html_notification_payload
          }, app_id: @app_result.app_id
        )
      end

      def txt_notification_payload
        @txt_notification_payload ||= SummaryBuilder.new(@app_result, :text).call
      end

      def html_notification_payload
        @html_notification_payload ||= SummaryBuilder.new(@app_result, :html).call
      end
    end
  end
end
