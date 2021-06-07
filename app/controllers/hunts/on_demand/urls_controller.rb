module Hunts::OnDemand
  # :nodoc
  class UrlsController < BaseController
    def create
      authorize current_account, :show?

      @on_demand_url = Hunts::OnDemandUrl.new(url_params)
      if @on_demand_url.valid?
        build_hunt!
        queue_hunts_broadcast!
        flash[:notice] = "On-Demand hunt created"
      end
    end

    private

    def url_params
      params.require(:hunts_on_demand_url).permit(:url)
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
      @hunt_test ||= Hunts::BrowserVisitTest.new
    end

    def hunt_test_condition
      @hunt_test_condition ||= Hunts::LikeCondition.new(
        operator: :contains, condition: url_params[:url]
      )
    end

    def hunt_name
      url_params[:url].split(",").to_sentence(last_word_connector: " or ")
    end
  end
end
