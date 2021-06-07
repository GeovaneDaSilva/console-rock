module Hunts::OnDemand
  # :nodoc
  class FilenamesController < BaseController
    def create
      authorize current_account, :show?

      @on_demand_filename = Hunts::OnDemandFilename.new(filename_params)
      if @on_demand_filename.valid?
        build_hunt!
        queue_hunts_broadcast!
        flash[:notice] = "On-Demand hunt created"
      end
    end

    private

    def filename_params
      params.require(:hunts_on_demand_filename).permit(:filename)
    end

    def build_hunt!
      hunt_test.conditions << hunt_test_condition
      hunt.tests << hunt_test

      hunt.save
    end

    def hunt
      @hunt ||= Hunt.new(
        name:      "On-Demand Hunt for #{hunt_name}",
        group:     current_account.groups.first,
        indicator: :informational,
        matching:  :all_tests,
        on_demand: true
      )
    end

    def hunt_test
      @hunt_test ||= Hunts::FileNameTest.new
    end

    def hunt_test_condition
      @hunt_test_condition ||= Hunts::LikeCondition.new(
        operator: :is_equal_to, condition: filename_params[:filename]
      )
    end

    def hunt_name
      filename_params[:filename].split(",").to_sentence(last_word_connector: " or ")
    end
  end
end
