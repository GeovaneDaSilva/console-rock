module Hunts::OnDemand
  # :nodoc
  class ProcessnamesController < BaseController
    def create
      authorize current_account, :show?

      @on_demand_processname = Hunts::OnDemandProcessname.new(processname_params)
      if @on_demand_processname.valid?
        build_hunt!
        queue_hunts_broadcast!
        flash[:notice] = "On-Demand hunt created"
      end
    end

    private

    def processname_params
      params.require(:hunts_on_demand_processname).permit(:processname)
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
      @hunt_test ||= Hunts::ProcessNameTest.new
    end

    def hunt_test_condition
      @hunt_test_condition ||= Hunts::LikeCondition.new(
        operator: :is_equal_to, condition: processname_params[:processname]
      )
    end

    def hunt_name
      processname_params[:processname].split(",").to_sentence(last_word_connector: " or ")
    end
  end
end
