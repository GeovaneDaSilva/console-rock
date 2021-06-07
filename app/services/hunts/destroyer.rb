module Hunts
  # More efficient destroy of hunts
  class Destroyer
    def initialize(hunt)
      @hunt = hunt
    end

    def call
      delete_hunt_results!

      @hunt.destroy
    end

    private

    def delete_hunt_results!
      @hunt.hunt_results.each do |hunt_result|
        hunt_result.test_results.delete_all
        hunt_result.destroy
      end
    end
  end
end
