# :nodoc
module LogicRulable
  extend ActiveSupport::Concern

  included do
    helper_method :logic_rule_path, :account_options, :operator_options, :action_options,
                  :incident_template_options
  end

  def show
    authorize scope, :create_logic_rules?

    @logic_rule = LogicRule.new
    @pagination, @logic_rules = pagy LogicRule.where(app_id: params[:app_id])

    render "triage/logic_rules/show"
  end

  def create
    authorize scope, :create_logic_rules?

    respond_to do |format|
      format.js do
        if params[:evaluate]
          evaluate_logic_rule!
        else
          create_logic_rule!
        end
      end
    end
  end

  private

  def scope
    raise NotImplementedError
  end

  def logic_rule_path(opts = {})
    raise NotImplementedError
  end

  def evaluate_logic_rule!
    opts = { app_results: params[:app_results], rules: params[:logic_rule][:rules] }
    response = Administration::LogicRules::Evaluate.new(app, scope, opts).call

    if response[:errors].blank?
      flash[:notice] = "Rule is valid. #{response[:matches]} matches found."
    else
      flash[:error] = response[:errors].join(", ")
    end
  end

  def create_logic_rule!
    logic_rule = ::Administration::LogicRuleFactory.build(params)
    if logic_rule.save
      flash[:notice] = "Successfully made rule"
      opts = { account_id: params[:account_id], app_results: params[:app_results] }
      redirect_to logic_rule_path(query_params.merge(opts))
    else
      flash[:error] = "Rule creation failed"
    end
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

  def incident_template_options
    @incident_template_options ||= ::LogicRules::IncidentTemplate.pluck(:name, :id)
  end
end
