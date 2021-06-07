module Accounts
  module Apps
    # Configure mapping between your AV sites and your RocketCyber customer names
    class AntivirusConfigController < AuthenticatedController
      helper_method :account, :sub_accounts, :app, :customer_list

      def index
        authorize account, :can_manage_apps?

        @map = AntivirusCustomerMap.where(account_id: sub_accounts.pluck(:id), app_id: app&.id)
                                   .map { |one| [one.account_id, { av_label: one.antivirus_id }] }.to_h
      end

      def create
        authorize account, :can_manage_apps?

        type, message = false, "Failed to save configuration"
        if params.dig(:config, :save_type) == "Route All Detections to A Single Customer"
          type, = :notice
          message = "Saved target customer"
        elsif params.dig(:config, :save_type) == "Route Detections to Customers Using AV Site IDs"
          type, message = save_antivirus_map
        end

        if app_config.update(config: config_params)
          flash[type] = message
        else
          flash[:error] = "Failed to save configuration"
        end

        redirect_back fallback_location: root_path
      end

      private

      def account
        @account ||= Account.find(params[:account_id])
      end

      def sub_accounts
        @sub_accounts ||= account.all_descendant_customers.order(:name)
      end

      def app
        @app ||= App.find_by(configuration_type: params[:config_type])
      end

      def customer_list
        @customer_list ||= account.all_descendant_customers.pluck(:name, :id)
      end

      def app_config
        @app_config ||= account.app_configs.find_or_initialize_by(app: app)
      end

      def config_params
        case params.dig(:config, :save_type)
        when "Route Detections to Customers Using AV Site IDs"
          params[:config].permit(:save_type).to_h
        when "Route All Detections to A Single Customer"
          params[:config].permit(:save_type, :target_customer).to_h
        else
          {}
        end
      end

      def save_antivirus_map
        failures = []

        (params[:map] || []).each do |key, value|
          record = AntivirusCustomerMap.where(
            account_id: key.to_i,
            app_id:     app&.id
          ).first_or_initialize

          record.assign_attributes(antivirus_id: value[:antivirus_id]) if value[:antivirus_id].present?

          if record.antivirus_id.present? && !record.save
            failures << sub_accounts.find_by(id: record.account_id)&.name || record.account_id
          end
        end

        if failures.blank?
          [:notice, "All data successfully saved"]
        else
          [:error, "The following customers failed to save: #{failures.join(', ')}"]
        end
      end
    end
  end
end
