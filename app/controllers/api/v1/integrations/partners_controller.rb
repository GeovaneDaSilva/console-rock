module Api
  module V1
    module Integrations
      # API endpoint allowing for CRUD (not delete yet) operations on Pax8 providers (they say partners)
      class PartnersController < Api::V1::Integrations::Pax8BaseController
        # by extending Pax8BaseController, these all have "authenticate" as a before_action

        def create
          build_provider

          if @provider.save
            create_users

            render json: build_response([@provider.reload])
          else
            render json: { error: "Provider save failed" }, status: :not_found
          end
        end

        def update
          target = account.self_and_all_descendants.find_by(id: params[:id]) # <--- id?

          if target.customer?
            render json: { error: "No partner found matching provided ID" }, status: :not_found
          elsif target.update(update_params) # <-- update_params filters out blanks
            render json: build_response([target.reload])
          else
            render json: { error: "Provider update failed" }, status: :not_found
          end
        end

        def index
          # TODO: STILL NEED TO TEST OFFSET, LIMIT, SORT
          left_out = []
          accounts = account.self_and_all_descendants.where(type: "Provider")
          if index_params[:id].blank?
            accounts = accounts.where(id: index_params[:ids]) if index_params[:ids].present?
            left_out = index_params[:ids].map(&:to_i) - accounts.pluck(:id) if index_params[:ids].present?
            accounts = accounts.offset(index_params[:offset]) if index_params[:offset].present?
            accounts = accounts.limit(index_params[:limit]) if index_params[:limit].present?
            accounts = accounts.order(index_params[:sort]) if index_params[:sort].present?
          else
            accounts = accounts.where(id: index_params[:id])
          end

          lefters = []
          left_out.each do |one|
            lefters << { id: one, result: "No account found" }
          end

          render json: build_response(accounts + lefters)
        end

        private

        def build_provider
          @provider = Provider.new(build_params)
          @provider.path = account&.path
          @provider.agent_release_group = account&.agent_release_group
          @provider.plan_id = plan_id
          @provider.name = nil if @provider.plan_id.nil?
        end

        def plan_id
          Plan.published.ids.include?(params[:plan].to_i) ? params[:plan] : nil
        end

        def invite_user(user)
          full_name = [user[:first_name], user[:last_name]].join(" ")
          ::UserInvitor.new(user[:email], full_name, account&.users&.first, false, @provider).call
        end

        def index_params
          @index_params ||= params.permit(:id, :offset, :limit, :sort, ids: []).to_h
        end

        def build_params
          available_params = params.permit(
            :name, :logo_id, :skip_nesting, :contact_name, :street_1, :street_2,
            :city, :state, :zip_code, :settings_inheritance, :alien_vault_api_key,
            :virus_total_api_key, :emails, :enable_customer_notifications, ids: []
          ).to_h

          available_params.merge!(
            params.permit(
              setting_attributes: %i[
                can_customize_logo channel url verbosity offline super polling
                parallel_sub_task_count file_hash_refresh_interval app_result_cache_age max_cpu_usage
                max_memory_usage max_sustained_memory_usage auto_remediate
              ]
            )
          )

          available_params
        end

        def update_params
          return @update_params if @update_params.present?

          @update_params = params.permit(
            :name, :logo_id, :skip_nesting, :contact_name, :street_1, :street_2,
            :city, :state, :zip_code, :settings_inheritance, :alien_vault_api_key,
            :virus_total_api_key, :emails, :enable_customer_notifications, ids: []
          ).to_h

          @update_params.merge!(
            params.permit(
              setting_attributes: %i[
                can_customize_logo channel url verbosity offline super polling
                parallel_sub_task_count file_hash_refresh_interval app_result_cache_age max_cpu_usage
                max_memory_usage max_sustained_memory_usage auto_remediate
              ]
            )
          )
          change_plans if @update_params.blank? && !params[:plan].nil?

          @update_params
        end

        def create_users
          (params[:users] || []).each do |new_user|
            user_role = @provider.user_roles.new(role: new_user[:role] || :owner)
            user_role.user = if params[:send_email]
                               invite_user(new_user.permit(:first_name, :last_name, :email))
                             else
                               make_user(new_user.permit(:first_name, :last_name, :email))
                             end
            if user_role.valid? && user_role.user.valid?
              user_role.save
              user_role.user.save if !params[:send_email]
            end
          end
        end

        def build_response(account_list)
          # rubocop:disable Layout/LineLength
          account_list.as_json(
            only: %i[id name path created_at updated_at contact_name street_1 city state country plan_id paid_thru type license_key]
          )
          # rubocop:enable Layout/LineLength
        end

        def make_user(new_user)
          password = SecureRandom.uuid
          User.new({
                     email:                 new_user[:email],
                     first_name:            new_user[:first_name],
                     last_name:             new_user[:last_name],
                     password:              password,
                     password_confirmation: password
                   })
        end

        def change_plans
          plan = Plan.find_by(id: params[:plan])
          return if plan.nil? || plan.trial?

          old_plan = account.plan
          paid_thru = account.billing_account.paid_thru

          if account.update(plan: plan, status: :active, paid_thru: paid_thru)
            Rails.logger.error("save start -- #{account.reload.plan_id}")
            ::Plans::SubscriptionChange.new(account, old_plan).call
            ::Accounts::PlanTransitioner.new(account).call
            ::Charges::Charger.new(account, account.plan).call if account.chargeable?
            Rails.logger.error("save end -- #{account.reload.plan_id}")
            @update_params = { plan_id: plan.id }
          end
        end
      end
    end
  end
end
