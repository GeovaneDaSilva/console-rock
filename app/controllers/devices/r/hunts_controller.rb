module Devices
  module R
    # Hunt report for a device and a hunt result
    class HuntsController < BaseController
      helper_method :device, :hunt_result, :network_connection_tests, :browser_visits_tests,
                    :files_tests, :processes_tests, :user_tests, :yara_tests,
                    :registry_tests, :service_tests, :event_tests, :driver_tests, :dns_tests,
                    :informational_tests

      def show
        authorize device, :show?
      end

      private

      def hunt_result
        @hunt_result ||= device.hunt_results
                               .includes(:hunt, test_results: [{ test: :conditions }])
                               .find(params[:id])
      end

      def network_connection_tests
        @network_connection_tests ||= hunt_result.test_results
                                                 .joins(:test)
                                                 .where(hunts_tests: { id: ::Hunts::Test.network })
      end

      def browser_visits_tests
        @browser_visits_tests ||= hunt_result.test_results
                                             .joins(:test)
                                             .where(hunts_tests: { id: ::Hunts::Test.browser })
      end

      def files_tests
        @files_tests ||= hunt_result.test_results
                                    .joins(:test)
                                    .where(hunts_tests: { id: ::Hunts::Test.file })
      end

      def processes_tests
        @processes_tests ||= hunt_result.test_results
                                        .joins(:test)
                                        .where(hunts_tests: { id: ::Hunts::Test.process })
      end

      def user_tests
        @user_tests ||= hunt_result.test_results
                                   .joins(:test)
                                   .where(hunts_tests: { id: ::Hunts::Test.user })
      end

      def yara_tests
        @yara_tests ||= hunt_result.test_results
                                   .joins(:test)
                                   .where(hunts_tests: { id: ::Hunts::Test.yara })
      end

      def registry_tests
        @registry_tests ||= hunt_result.test_results
                                       .joins(:test)
                                       .where(hunts_tests: { id: ::Hunts::Test.registry })
      end

      def service_tests
        @service_tests ||= hunt_result.test_results
                                      .joins(:test)
                                      .where(hunts_tests: { id: ::Hunts::Test.service })
      end

      def event_tests
        @event_tests ||= hunt_result.test_results
                                    .joins(:test)
                                    .where(hunts_tests: { id: ::Hunts::Test.event })
      end

      def driver_tests
        @driver_tests ||= hunt_result.test_results
                                     .joins(:test).where(hunts_tests: { id: ::Hunts::Test.driver })
      end

      def dns_tests
        @dns_tests ||= hunt_result.test_results
                                  .joins(:test)
                                  .where(hunts_tests: { id: ::Hunts::Test.dns })
      end

      def informational_tests
        @informational_tests ||= hunt_result.test_results
                                            .joins(:test)
                                            .where(hunts_tests: { id: ::Hunts::Test.informational })
      end
    end
  end
end
