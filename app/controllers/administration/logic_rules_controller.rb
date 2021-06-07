module Administration
  # :nodoc
  class LogicRulesController < BaseController
    include Pagy::Backend

    helper_method :operator_to_text, :account_options, :operator_options, :action_options,
                  :dependency_options, :incident_template_options,
                  :av_action_options, :av_action_value_options

    def index
      authorize(current_user, :soc_team?)

      @pagy, @logic_rules = pagy(LogicRule.all)
    end

    def show
      authorize(current_user, :soc_team?)

      @logic_rule = LogicRule.find(params[:id])
      @rules = build_rules_view(@logic_rule.rules)
    end

    def new
      authorize(current_user, :soc_team?)

      @logic_rule = LogicRule.new
      @apps = App.order(:title)
      @app_options = @apps.pluck(:title, :id)
    end

    def create
      authorize(current_user, :soc_team?)

      logic_rule = Administration::LogicRuleFactory.build(params)
      if logic_rule.save
        flash[:notice] = "Successfully made rule"
        redirect_to administration_logic_rule_path(logic_rule)
      else
        flash[:error] = "Rule creation failure"
      end
    end

    def edit
      authorize(current_user, :soc_team?)

      @logic_rule = LogicRule.find(params[:id])
      @apps = App.order(:title)
      @app_options = @apps.pluck(:title, :id)
      @rules = build_rules_view(@logic_rule.rules)
    end

    def update
      authorize(current_user, :soc_team?)

      logic_rule = Administration::LogicRuleFactory.build(params)
      if logic_rule.save
        flash[:notice] = "Successfully saved rule"
        redirect_to administration_logic_rule_path(logic_rule)
      else
        flash[:error] = "Rule update failure"
      end
    end

    def destroy
      authorize(current_user, :soc_team?)

      @logic_rule = LogicRule.find(params[:id])
      if @logic_rule.destroy
        flash[:notice] = "Rule deleted"
        redirect_to administration_logic_rules_path
      else
        flash[:error] = "Unable to delete rule"
        redirect_to administration_logic_rule_path(logic_rule)
      end
    end

    private

    def build_rules_view(rules)
      rules.map do |rule|
        {
          logic:      rule.key?("and") ? "ALL" : "ANY",
          conditions: build_conditions_view(rule["and"] || rule["or"])
        }
      end
    end

    def build_conditions_view(conditions)
      conditions.map do |condition|
        data = condition.to_a.flatten
        attributes = %i[operator attribute value]
        case data[0]
        when "!"
          subdata = data[1].to_a.flatten
          values = [
            operator_to_text["not in"],
            subdata[1]["var"] || subdata[1],
            subdata[2]["var"] || subdata[2]
          ]
        when "in"
          values = [operator_to_text[data[0]], data[2]["var"], data[1]]
        else
          values = [operator_to_text[data[0]], data[1]["var"], data[2]]
        end
        attributes.zip(values).to_h
      end
    end

    def operator_to_text
      @operator_to_text ||= {
        "=="     => "equals",
        "!="     => "is not",
        ">"      => ">",
        ">="     => ">=",
        "<"      => "<",
        "<="     => "<=",
        "in"     => "includes",
        "not in" => "is not in"
      }
    end

    def account_options
      @account_options ||= [["all accounts", nil]] + Account.active.pluck(:name, :id)
    end

    def operator_options
      @operator_options ||= {
        "equals"    => "==",
        "is not"    => "!=",
        ">"         => ">",
        ">="        => ">=",
        "<"         => "<",
        "<="        => "<=",
        "includes"  => "in",
        "is not in" => "not in"
      }.to_a
    end

    def action_options
      @action_options ||= {
        "Email SOC"         => "Pipeline::Alert::EmailSoc",
        "Create Incident"   => "Pipeline::Actions::CreateIncident",
        "Perform AV Action" => "Pipeline::Actions::PerformAvAction",
        "Isolate"           => "Pipeline::Actions::Isolate"
      }.to_a
    end

    def dependency_options
      @dependency_options ||= {
        "Fetch App Configs" => "Pipeline::Dependencies::FetchAppConfig"
      }.to_a
    end

    def incident_template_options
      @incident_template_options ||= ::LogicRules::IncidentTemplate.pluck(:name, :id)
    end

    def av_action_options
      case @logic_rule.app.configuration_type
      when "sentinelone"
        ["Analyst Verdict", "Mitigation Action", "Whitelist"]
      else
        []
      end
    end

    def av_action_value_options(av_action)
      case av_action
      when "Analyst Verdict"
        %w[undefined true_positive false_positive suspicious]
      when "Mitigation Action"
        %w[kill quarantine remediate rollback disconnectFromNetwork]
      when "Whitelist"
        ["by file hash"]
      else
        []
      end
    end
  end
end
