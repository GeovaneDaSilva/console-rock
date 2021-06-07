module Broadcasts
  # :nodoc
  class Analysis < Base
    def initialize(analysis)
      @analysis = analysis
    end

    def call
      return unless active_channel?(channel_name)

      ActionCable.server.broadcast(channel_name, analysis_html)

      true
    end

    private

    def channel_name
      "analysis:#{@analysis.id}"
    end

    def analysis_html
      AuthenticatedController.renderer.render(
        partial: "analysis/show", locals: { analysis: @analysis }
      ).squish
    end
  end
end
