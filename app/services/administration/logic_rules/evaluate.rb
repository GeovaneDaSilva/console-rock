require "json_logic"

module Administration
  module LogicRules
    # Evaluates a Logic Rule against App Results
    class Evaluate
      class MissingLogicRuleConditions < StandardError; end
      class SelectedAppResultsRequired < StandardError; end

      def initialize(app, scope, params = {})
        @app = app
        @scope = scope
        @params = params.with_indifferent_access
        @errors = []
        @matches = 0
      end

      def call
        begin
          validate!
          evaluate_rules
        rescue MissingLogicRuleConditions, SelectedAppResultsRequired => e
          @errors << e.message
        end
        { matches: @matches, errors: @errors }
      end

      private

      def app_results
        @app_results ||= case @scope.class
                         when Device
                           Apps::DeviceResult.where(id: @params[:app_results])
                         else
                           Apps::Result.where(id: @params[:app_results])
                         end
      end

      def rules
        @rules ||= ::Administration::LogicRuleFactory.build_rules(@params[:rules])
      end

      def evaluate_rules
        rules.each do |rule|
          app_results.each do |app_result|
            @matches += 1 if JSONLogic.apply(rule, app_result["details"])
          end
        end
      end

      def validate!
        raise_selected_app_results_required if @params[:app_results].blank?
        raise_missing_logic_rule_conditions if @params[:rules].blank?
        @params[:rules].each { |rule| validate_conditions!(rule[:conditions]) }
      end

      def validate_conditions!(conditions)
        raise_missing_logic_rule_conditions if conditions.blank?

        conditions.each { |condition| validate_field!(condition[:attribute]) }
      end

      def validate_field!(field)
        app_results.each do |app_result|
          next if JSONLogic.apply({ "var" => [field] }, app_result["details"])

          @errors << "Field \"#{field}\" was not found"
          break
        end
      end

      def raise_selected_app_results_required
        raise SelectedAppResultsRequired, "No selected app results"
      end

      def raise_missing_logic_rule_conditions
        raise MissingLogicRuleConditions, "Missing logic rule conditions"
      end
    end
  end
end
