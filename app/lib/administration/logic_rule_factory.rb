module Administration
  # :nodoc
  class LogicRuleFactory
    def self.build(params = {})
      actions = build_actions(params.dig(:logic_rule, :actions))
      dependencies = build_dependencies(params.dig(:logic_rule, :dependencies))
      rules = params.dig(:logic_rule, :rules) || []
      logic_rule = params[:id] ? LogicRule.find(params[:id]) : LogicRule.new
      logic_rule.tap do |lr|
        lr.user_id     = params[:user_id]
        lr.account_id  = params.dig(:account_id)
        lr.app_id      = params.dig(:logic_rule, :app_id)
        lr.description = params.dig(:logic_rule, :description)
        lr.rules       = build_rules(rules, dependencies)
        lr.actions     = actions
        lr.dependencies = dependencies
      end
    end

    def self.build_rules(rules = [], dependencies = [])
      rules.map do |rule|
        { rule[:logic] => build_conditions(rule[:conditions], dependencies) }
      end
    end

    def self.build_conditions(conditions, dependencies)
      Array(conditions).map do |condition|
        next if condition[:attribute].blank?

        condition[:value] = nil if condition[:value] == "nil"
        condition[:value] = JSON(condition[:value]) unless condition[:value]&.match(/\[.*\]/).nil?

        if condition[:operator] == "in"
          { condition[:operator] => [condition[:value], { "var" => condition[:attribute] }] }
        elsif condition[:operator] == "not in"
          attribute = determine_attibute(condition[:attribute], dependencies)
          { "!" => { "in" => [attribute, { "var" => condition[:value] }] } }
        else
          { condition[:operator] => [{ "var" => condition[:attribute] }, condition[:value]] }
        end
      end.compact
    end

    def self.build_actions(actions)
      return [] if actions.blank?

      actions.map do |action|
        case action[:name]
        when "Pipeline::Actions::PerformAvAction"
          [action[:name], action[:av_vendor], action[:av_action], action[:av_action_option]].join(",")
        else
          [action[:name], action[:template_id], action[:reset_time], action[:matching_fields]].join(",")
        end
      end
    end

    def self.determine_attibute(attribute, dependencies)
      if dependencies.include?(attribute)
        attribute
      else
        { "var" => attribute }
      end
    end

    # This turns each into a single string, only to turn it back into an array on the other end.
    # In the future, may be better to have as array all the way through
    def self.build_dependencies(dependencies)
      return [] if dependencies.blank?

      dependencies.map { |n| "#{n['target']},#{n['attribute']}" } || []
    end
  end
end
