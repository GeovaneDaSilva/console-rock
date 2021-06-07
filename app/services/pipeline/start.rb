# :nodoc
module Pipeline
  # :nodoc
  class Start
    def initialize(params = {})
      @params = params
    end

    def call
      return if @params[:result_id].nil?

      ServiceRunnerJob.perform_later("Pipeline::Analysis::RunAllLogicRules", @params[:result_id])
    end
  end
end
