require "json_logic"

# :nodoc
module Pipeline
  # :nodoc
  module Analysis
    # :nodoc
    class RunOneRule
      def initialize(app_result_id, log_rule_id, counter = 1)
        @result = ::Apps::Result.find(app_result_id)
        @rule = LogicRule.find(log_rule_id)
        @counter = counter
        @billing_account = Account.find_by(id: @result.customer_id).billing_account
      rescue ActiveRecord::RecordNotFound
        @result = nil
      end

      def call
        return if @result.nil? || @result.detection_date < 1.day.ago || !@result.incident_id.nil?
        return if !@rule.account_id.nil? && @result.customer_id != @rule.account_id
        return unless @billing_account&.managed?

        if @counter >= 5
          Rails.logger.error("LogicRuleRunner ran too many times -- possible loop for "\
          "app result: #{@result.id}, app: #{@result.app_id}, rule: #{@rule.id}")
          return
        end

        dependencies = calculate_dependencies
        return if dependencies.nil?

        begin
          apply_actions if evaluate_rule(dependencies)
        rescue NoMethodError
          # Rails.logger.warn("Logic rule did not have all needed vars.\t"\
          # "Rule: #{@rule.id}, result: #{@result.id}")
        end
      end

      private

      def calculate_dependencies
        return {} if @rule.dependencies.blank?

        calculated_dependencies = Rails.cache.read_multi(*@rule.dependencies)

        # For now, assume it is an account config.
        # Get the value from cache, and set the call = 1 because the existing logic checks to see if the
        # dependencies all have non-nil values (here, the dependency is not the value in the logic rule)
        #   - could force it to match, but ... that doesn't seem right for some reason
        # ...(I may regret that decision)
        @rule.dependencies.find_all { |n| n =~ /Pipeline::Dependencies::FetchAppConfig/ }.each do |call|
          service, attribute = call.split(",")

          key = [service&.parameterize(separator: "_"), @result.app_id, @result.customer_id, attribute]
          calculated_dependencies[attribute] = Rails.cache.read(key)
          calculated_dependencies[call] = "1" unless calculated_dependencies[attribute].nil?
        end

        # if any of the return values were nil, that means at least one of the dependencies has not been
        # calculated (because is not in cache).
        if !@rule.dependencies.all? { |s| calculated_dependencies.key? s } || calculated_dependencies.blank?
          ServiceRunnerJob.set(wait: rand(10..100).seconds).perform_later(
            "Pipeline::Analysis::RunOneRule", @result.id, @rule.id, @counter + 1
          )
          nil
        else
          calculated_dependencies
        end
      end

      def evaluate_rule(dependencies)
        gate = JSONLogic.apply(@rule.rules, @result["details"].merge(dependencies))
        gate.class == Array ? gate.first : gate
      end

      def apply_actions
        @rule.actions.each do |action|
          service, template_id, reset_time, *fields = action.split(",")
          message = nil
          ServiceRunnerJob.perform_later(
            service, message, @rule.id, @result.id, template_id, reset_time, fields
          )
        end
      end
    end
  end
end
