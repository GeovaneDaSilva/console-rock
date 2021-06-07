module Accounts
  # Display integrations page
  class IntegrationsController < AuthenticatedController
    extend Lettable

    before_action { authorize(account, :can_manage_integrations?) }

    let(:account) { current_account }
    let(:connectwise_credential) { ::Credentials::Connectwise.find_or_initialize_by(account_id: account.id) }
    let(:datto_credential) { ::Credentials::Datto.find_or_initialize_by(account_id: account.id) }
    let(:syncro_credential) { ::Credentials::Syncro.find_or_initialize_by(account_id: account.id) }
    let(:kaseya_credential) { ::Credentials::Kaseya.find_or_initialize_by(account_id: account.id) }
    let(:psa_config) { current_account.psa_config || PsaConfig.new }
    let(:maps) { RocketcyberIntegrationMap.where(account: sub_accounts) }

    helper_method :emails, :phones, :apps, :antivirus_customer_maps, :sub_accounts,
                  :integrations_mask, :dropdown_formatted_sub_accounts

    def index; end

    def cylance
      authorize current_account, :can_manage_apps?

      @account = Account.find(params[:customer_id])
      render json: {
        html: render_to_string("accounts/integrations/_cylance",
                               layout:  false,
                               locals:  {
                                 account:    @account,
                                 credential: @cred
                               },
                               formats: :slim)
      }
    end

    private

    def emails
      @emails ||= account.email_addresses || []
    end

    def phones
      @phones ||= account.phones
    end

    def apps
      return @myapps if @myapps

      @myapps = { antivirus: [] }
      type = account.type.downcase.to_sym
      (account.billing_account.plan.apps.where(":scope = ANY(configuration_scopes)", scope: type) + \
       account.apps.where(":scope = ANY(configuration_scopes)", scope: type)).uniq.each do |app|
        tabs.each do |t, types|
          next unless types.include? app.configuration_type

          @myapps[t] = [] unless @myapps[t]
          next if t.eql?(:microsoft) && !@myapps[t].empty?

          @myapps[t] << app
        end
      end
      @myapps
    end

    def tabs
      {
        microsoft:      %w[office365],
        antivirus:      %w[sentinelone webroot bitdefender deep_instinct sophos_av],
        email_security: %w[ironscales ess sen],
        network:        %w[dns_filter],
        dark_web:       %w[hibp],
        mfa:            %w[passly duo]
      }
    end

    def antivirus_customer_maps
      a_ids = current_account.self_and_all_descendants.pluck(:id)
      app_ids = apps.collect { |_type, app| app.pluck(:id) }.flatten.uniq
      return AntivirusCustomerMap.where(account_id: a_ids, app_id: app_ids) if a_ids.present?

      nil
    end

    def sub_accounts
      @sub_accounts ||= account.all_descendant_customers.order(:name)
    end

    def dropdown_formatted_sub_accounts
      @dropdown_formatted_sub_accounts ||= sub_accounts.collect { |a| [a.name, a.id] }
    end

    def integrations_mask(str)
      return str if current_user&.admin?

      helpers.mask(str)
    end
  end
end
