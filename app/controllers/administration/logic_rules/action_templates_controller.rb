module Administration
  module LogicRules
    # Admin views for logic rule action templates
    class ActionTemplatesController < Administration::BaseController
      include Pagy::Backend

      helper_method :template_types

      def index
        authorize :administration, :view_action_templates?

        @pagination, @templates = pagy ::LogicRules::ActionTemplate.all
      end

      def show
        authorize :administration, :view_action_templates?

        @template = ::LogicRules::ActionTemplate.find(params[:id])
      end

      def new
        authorize :administration, :manage_action_templates?
      end

      def create
        authorize :administration, :manage_action_templates?

        template = ::LogicRules::ActionTemplate.new(action_template_params)
        if template.save
          flash[:notice] = "Successfully created template"
          redirect_to administration_logic_rules_action_template_path(template)
        else
          flash[:error] = "Unable to create template"
          redirect_to new_administration_logic_rules_action_template_path
        end
      end

      def edit
        authorize :administration, :manage_action_templates?

        @template = ::LogicRules::ActionTemplate.find(params[:id])
      end

      def update
        authorize :administration, :manage_action_templates?

        template = ::LogicRules::ActionTemplate.find(params[:id])
        if template.update(action_template_params)
          flash[:notice] = "Successfully updated template"
          redirect_to administration_logic_rules_action_template_path(template)
        else
          flash[:error] = "Unable to update template"
          redirect_to edit_administration_logic_rules_action_template_path(template)
        end
      end

      def destroy
        authorize :administration, :manage_action_templates?

        template = ::LogicRules::ActionTemplate.find(params[:id])
        if template.destroy
          flash[:notice] = "Template deleted"
          redirect_to administration_logic_rules_action_templates_path
        else
          flash[:error] = "Unable to delete template"
          redirect_to administration_logic_rules_action_template_path(template)
        end
      end

      private

      def action_template_params
        params.require(:logic_rules_action_template).permit(
          :type, :name, details: %i[title description remediation]
        ).to_h
      end

      def template_types
        @template_types ||= {
          "Incident" => "LogicRules::IncidentTemplate"
        }.to_a
      end
    end
  end
end
