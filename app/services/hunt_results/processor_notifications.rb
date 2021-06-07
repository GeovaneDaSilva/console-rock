module HuntResults
  # Processor notification
  module ProcessorNotifications
    def notify_subscriptions!
      notify_subscribers_of_event(:malicious_indicator) if @hunt_result.malicious?
      notify_subscribers_of_event(:suspicious_indicator) if @hunt_result.suspicious?
    end

    def notify_subscribers_of_event(event)
      ServiceRunnerJob.perform_later(
        "EventPublisher",
        @hunt_result.device.customer, @hunt_result.device, event.to_s, message: {
          txt: txt_notification_payload, html: html_notification_payload
        }
      )
    end

    def txt_notification_payload
      @txt_notification_payload ||= SummaryBuilder.new(@hunt_result, :text).call
    end

    def html_notification_payload
      @html_notification_payload ||= SummaryBuilder.new(@hunt_result, :html).call
    end
  end
end
