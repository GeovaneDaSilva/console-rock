module Apps
  module Results
    # Generate summary of the app result
    class SummaryBuilder
      def initialize(app_result, format = :text)
        @app_result = app_result
        @format     = format
      end

      def call
        ApplicationController.renderer.render(
          partial: "apps/results/summary", locals: { app_result: @app_result }, formats: @format
        )
      end
    end
  end
end
