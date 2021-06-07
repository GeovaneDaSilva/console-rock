require "json_logic"

# :nodoc
module Pipeline
  # :nodoc
  module Analysis
    # :nodoc
    class RunAllLogicRules
      def initialize(app_result_id)
        @result = ::Apps::Result.find(app_result_id)
        @rules = LogicRule.where(app_id: @result.app_id)
        @billing_account = Account.find_by(id: @result.customer_id).billing_account
      rescue ActiveRecord::RecordNotFound
        @result = nil
      end

      def call
        return if @result.nil? || @rules.blank? || @result.detection_date < 1.day.ago
        return unless @billing_account&.managed?

        # *************
        # json_logic var names CANNOT have periods in them, or JSONLogic will fail (always give false)
        #
        # be careful, because nil valuse appeare to be interpreted as "0" for numerical comparisons
        # i.e. "<" => [{"var" => "zzzz"}, 100] will evalutate to true if no value of "zzzz" is given
        # (because nil = 0 is less than 100) the same with ">" will eval to by the same logic

        # ******* NEED SOMEHOW TO ENSURE THAT ALL SERVICES CALLED BY THIS
        # => 1) WRITE TO CACHE
        # => 2) WRITE TO CACHE WITH A REASONABLE EXPIRATION
        # =>    (I'm thinking 10 min, ttl another 10, exceptions for special cases)

        @rules.each do |rule|
          next if !rule.account_id.nil? && @result&.customer_id != rule&.account_id

          dependency_hash = rule.dependencies.blank? ? {} : Rails.cache.read_multi(*rule.dependencies)

          # if any of the return values were nil, that means at least one of the dependencies has not been
          # calculated (because is not in cache).
          # So run the ones that have not been calculated and try this again later.
          # the exception is if dependency_hash is {} because there were no dependencies
          next if generate_dependencies(rule, dependency_hash)

          begin
            if evaluate_rule(rule, dependency_hash)
              rule.actions.each do |action|
                service, template_id, reset_time, *fields = action.split(",")
                message = nil
                ServiceRunnerJob.perform_later(
                  service, message, rule.id, @result.id, template_id, reset_time, fields
                )
              end
            end
          rescue NoMethodError
            next
          end
        end
      end

      # rubocop:disable Rails/Present
      def needed?(rule, dependency_hash)
        dependency_hash.blank? && !rule.dependencies.blank?
      end
      # rubocop:enable Rails/Present

      def generate_dependencies(rule, dependency_hash)
        if !rule.dependencies.all? { |s| dependency_hash.key? s } || needed?(rule, dependency_hash)

          (rule.dependencies - dependency_hash.keys).each do |key|
            pieces = key.split(",") + [@result.id]
            # Call below assumes that those methods all save to cache when they are done
            ServiceRunnerJob.perform_later(pieces[0], *pieces[1..-1])
          end
          ServiceRunnerJob.set(wait: rand(10..100).seconds).perform_later(
            "Pipeline::Analysis::RunOneRule", @result.id, rule.id
          )
          true
        else
          false
        end
      end

      def evaluate_rule(rule, dependency_hash)
        gate = JSONLogic.apply(rule.rules, @result["details"].merge(dependency_hash))
        gate.class == Array ? gate.first : gate
      end
    end
  end
end
