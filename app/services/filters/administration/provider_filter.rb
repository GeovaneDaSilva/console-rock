module Filters
  module Administration
    # Filter down a list of providers based on given parameters
    class ProviderFilter
      def initialize(params)
        @params = params
        @scope = Provider.not_marked_for_deletion
      end

      def call
        search
        apply_scopes
        apply_plan_where
        apply_status_where

        @scope
      end

      private

      def search
        return if @params[:search].blank?

        result = @scope.fuzzy_search(name: @params[:search])

        @scope = result.size.positive? ? result : @scope.basic_search(name: @params[:search])
      end

      def apply_scopes
        @scope = @scope.send(@params[:payment_status]) if valid_payment_status_scope?
        @scope = @scope.send(@params[:agent_release_group]) if @params[:agent_release_group].present?
      end

      def apply_plan_where
        return if @params[:plan_id].blank?

        @scope = @scope.where(plan_id: @params[:plan_id])
      end

      def apply_status_where
        return if @params[:status].blank?

        @scope = @scope.where(status: @params[:status])
      end

      def valid_payment_status_scope?
        %w[trial current past_due trial_expired].include?(@params[:payment_status])
      end

      alias filter call
    end
  end
end
