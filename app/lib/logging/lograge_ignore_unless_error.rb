module Logging
  # ignores normal statuses on high-active endpoints
  #
  # init with an array of Controller#Action strings (e.g., ProvidersController#show)
  # call returns true if the event should be ignored
  class LogrageIgnoreUnlessError
    def initialize(actions)
      @actions = actions
      setup!
    end

    attr_reader :actions, :structured_controller_actions, :controller_set

    def call(event)
      if matches_ignores?(event) && status_is_normal?(event)
        true
      else
        false
      end
    end

    private

    def status_is_normal?(event)
      return true if event.payload[:status].nil?

      (100...300).cover?(event.payload[:status])
    end

    def matches_ignores?(event)
      payload = event.payload
      controller_like = payload[:controller] || payload[:channel_class] || payload[:connection_class]

      return false unless controller_set.include?(controller_like)

      action_ignores = structured_controller_actions[controller_like]
      action_ignores.include?(payload[:action])
    end

    def setup!
      hash = {}

      actions.each do |action|
        controller, method = action.split("#")

        if hash[controller].present?
          hash[controller] << method
        else
          hash[controller] = [method]
        end
      end

      @structured_controller_actions = hash
      @controller_set = structured_controller_actions.keys.to_set
    end
  end
end
