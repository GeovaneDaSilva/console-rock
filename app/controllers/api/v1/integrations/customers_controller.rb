module Api
  module V1
    module Integrations
      # API endpoint for CRUD operations on customers (MSP's customers)
      class CustomersController < Api::V1::Integrations::Pax8BaseController
        # by extending Pax8BaseController, these all have "authenticate" as a before_action

        def create
          @provider = account.self_and_all_descendants.find_by(id: params[:partner_id])

          if !@provider.nil?
            build_customer
            if @customer.save
              render json: build_response([@customer])
            else
              render json: { error: "Customer save failed" }, status: :not_found
            end
          else
            render json: { error: "No partner found matching provided partner id" }, status: :not_found
          end

          # for this must have
          #   1) account name
          #   2) an email of someone associated, who you want me to send a setup email to
          #     -- not necessarily needed, because can inherit from parent
          #       + BUT PAX 8 WILL WANT TO DO IT THIS WAY, SINCE THE ALTERNATIVE IS THE
          #       (less efficient) MANUAL OPTION
          #   3) we will put you under the super-account's plan
          #
          #   all other information is optional
        end

        def update
          # puts params
          # puts account.all_descendants.pluck(:id)
          # puts params[:id]
          # puts account.all_descendants.find_by_id(params[:id])
          # puts customer_params
          target = account.all_descendant_customers.find_by(id: params[:id])
          if target.nil?
            render json: { error: "No customer found with provided ID" }, status: :not_found
          elsif target.update(customer_params) # <-- customer_params filters out blanks
            render json: build_response([target])
          else
            render json: { error: "Customer save failed" }, status: :not_found
          end
          # TODO: test what happens when
          # 1) you pass in an invalid id
          # 2) you pass in an attempt at SQL injection as ID
          # 3) you pass in nothing to update
          # 4) you pass in bad updates (?)
          # ditto for partner controller
        end

        def index
          accounts = account.all_descendant_customers
          if params[:id]
            accounts = accounts.where(id: params[:id]) if params[:id].present?
          else
            accounts = accounts.where(id: params[:ids]) if params[:ids].present?
            accounts = accounts.offset(params[:offset]) if params[:offset].present?
            accounts = accounts.limit(params[:limit]) if params[:limit].present?
            accounts = accounts.order(params[:sort]) if params[:sort].present?
          end

          render json: build_response(accounts)
        end

        private

        def build_customer
          @customer = Customer.new(customer_params)
          @customer.path = @provider.path
          @customer.agent_release_group = @provider.agent_release_group
        end

        def customer_params
          params.permit(
            :name, :logo_id, :skip_nesting, :contact_name, :street_1, :street_2,
            :city, :state, :zip_code, :settings_inheritance, :alien_vault_api_key,
            :virus_total_api_key, :emails, :enable_customer_notifications
          ).to_h
        end

        def build_response(account_list)
          # rubocop:disable Layout/LineLength
          account_list.as_json(
            only: %i[id name path created_at updated_at contact_name street_1 city state country plan_id paid_thru type license_key]
          )
          # rubocop:enable Layout/LineLength
        end
      end
    end
  end
end
