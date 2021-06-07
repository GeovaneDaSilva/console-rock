module Hunts::OnDemand
  # :nodoc
  class FilehashesController < BaseController
    def create
      authorize current_account, :show?

      @on_demand_filehash = Hunts::OnDemandFilehash.new(filehash_params)
      if @on_demand_filehash.valid?
        build_hunt!
        queue_hunts_broadcast!
        flash[:notice] = "On-Demand hunt created"
      end
    end

    private

    def filehash_params
      params.require(:hunts_on_demand_filehash).permit(:filehash)
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
      @hunt_test ||= Hunts::FileHashTest.new
    end

    def hunt_test_condition
      @hunt_test_condition ||= Hunts::LikeCondition.new(
        operator: :is_equal_to, condition: filehash_params[:filehash]
      )
    end

    def hunt_name
      filehash_params[:filehash].split(",").to_sentence(last_word_connector: " or ")
    end
  end
end
