module HuntResults
  # Generate summary of the hunt result
  class SummaryBuilder
    def initialize(hunt_result, format = :text)
      @hunt_result = hunt_result
      @format      = format
    end

    def call
      ApplicationController.renderer.render(
        partial: "hunt_results/summary", locals: { hunt_result: @hunt_result }, formats: @format
      )
    end
  end
end
