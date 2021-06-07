module Accounts
  # CRUD operations on PSA credentials
  class CredentialsController < AuthenticatedController
    extend Lettable

    let(:psa_config) { account.psa_config || PsaConfig.new(account: account) }

    attr_reader :credential

    def create
      authorize account, :can_manage_integrations?

      credential = Credential.new({ account_id: account.id, expiration: 1.day.ago }.merge(credential_params))
      if credential_save(credential)
        @job_setup_psa_config = setup_psa_config(credential)

        if params[:import_customers]
          redirect_to account_psa_customer_map_index_path(account)
          # redirect_to account_psa_customer_creation_index_path(account)
          return
        end
      else
        flash[:error] = "Error saving integration: #{credential.errors.full_messages.join(', ')}"
      end

      redirect_back_with_params
    end

    # rubocop:disable Metrics/MethodLength
    def update
      authorize account, :can_manage_integrations?

      credential = Credential.find_by(account_id: account.id, type: credential_type)
      credential.assign_attributes(credential_params) unless credential_params.nil?

      if params[:re_sync]
        @job_re_pull_setup_data = re_pull_setup_data(credential)
        unless params[:import_customers]
          redirect_back_with_params
          return
        end
      end

      if params[:import_customers]
        redirect_to account_psa_customer_map_index_path(
          account,
          re_pull:         true,
          credential_type: credential_type
        )
        return
      end

      if credential.changed? && credential_save(credential)
        flash[:notice] = "Integration updated successfully"
      elsif !psa_config.new_record?
        psa_config.assign_attributes(psa_config_params)
        @job_pull_board_statuses = pull_board_statuses(credential) if psa_config.changed? && psa_config.save
      end

      @connectwise_credential = ::Credentials::Connectwise.find_or_initialize_by(account_id: account.id)
      @datto_credential = ::Credentials::Datto.find_or_initialize_by(account_id: account.id)
      @syncro_credential = ::Credentials::Syncro.find_or_initialize_by(account_id: account.id)
      @kaseya_credential = ::Credentials::Kaseya.find_or_initialize_by(account_id: account.id)

      redirect_back_with_params
    end

    # rubocop:enable Metrics/MethodLength

    def destroy
      authorize account, :can_manage_integrations?

      credential = Credential.find_by(id: params[:id], account_id: params[:account_id])
      if credential.nil?
        flash[:error] = "No credential found"
      else
        ServiceRunnerJob.perform_later("Credentials::Destroy", credential.id)
        flash[:notice] = "Credential and associated config queued for deletion"
      end

      redirect_back fallback_location: root_url
    end

    private

    def redirect_back_with_params
      hash = poll_parameters
      uri = URI request.env["HTTP_REFERER"]
      if uri.present? && uri != request.env["REQUEST_URI"]
        new_params = Rack::Utils.parse_query(uri.query)
        hash.each do |k, v|
          new_params.delete(k)
          new_params[k.to_s] = v
        end
        uri.query = new_params.to_param
        redirect_to uri.to_s
      else
        redirect_to root_url
      end
    rescue ArgumentError
      redirect_to root_url
    end

    def poll_parameters
      hash = {
        job_re_pull_setup_data:  @job_re_pull_setup_data&.job_id,
        job_pull_board_statuses: @job_pull_board_statuses&.job_id,
        job_setup_psa_config:    @job_setup_psa_config&.job_id
      }.compact
      hash.merge!({ credential_type: credential_type.gsub("Credentials::", "").downcase })
    end

    def credential_save(credential)
      response = connection_test_type.constantize.new(params.permit!).call
      credential.is_working = response[:code] == 200
      credential.save!
      psa_config.credential = credential
      psa_config.psa_type = credential.psa_type
      psa_config.save!
    end

    def connection_test_type
      if params[:credentials_connectwise]
        "Integrations::Connectwise::ConnectionTest"
      elsif params[:credentials_datto]
        "Integrations::Datto::ConnectionTest"
      elsif params[:credentials_syncro]
        "Integrations::Syncro::ConnectionTest"
      elsif params[:credentials_kaseya]
        "Integrations::Kaseya::ConnectionTest"
      end
    end

    def credential_type
      if params[:credentials_connectwise]
        "Credentials::Connectwise"
      elsif params[:credentials_datto]
        "Credentials::Datto"
      elsif params[:credentials_syncro]
        "Credentials::Syncro"
      elsif params[:credentials_kaseya]
        "Credentials::Kaseya"
      end
    end

    def account
      @account ||= current_account
    end

    def credential_params
      # rubocop:disable Layout/LineLength
      cred_params = params[:credentials_connectwise] || params[:credentials_datto] || params[:credentials_syncro] || params[:credentials_kaseya]
      # rubocop:enable Layout/LineLength
      cred_params[:type] = cred_params[:type].to_sym
      cred_params.permit(:type, :connectwise_company_id, :connectwise_psa_public_api_key,
                         :connectwise_psa_private_api_key, :base_url, :datto_psa_username, :datto_psa_secret,
                         :syncro_api_key, :kaseya_username, :kaseya_password, :kaseya_tenant)
                 .each_pair { |_key, value| value.try(:strip!) }
                 .reject { |_key, value| helpers.masked?(value.to_s) }
    end

    def psa_config_params
      params.permit(:board, :new_ticket_code, :in_progress_ticket_code, :closed_ticket_code,
                    :ticket_type, :ticket_source, :priority)
    end

    def setup_psa_config(credential)
      flash[:notice] = "Setting up your PSA information."
      ServiceRunnerJob.perform_later("Integrations::InitializePsaConfig::SetupPsaConfig",
                                     credential.type.split("::").last,
                                     credential,
                                     psa_config)
    end

    def pull_board_statuses(credential)
      flash[:notice] = "Pulling statuses information."
      ServiceRunnerJob.perform_later("Integrations::InitializePsaConfig::PullBoardStatuses",
                                     credential.type.split("::").last,
                                     credential,
                                     psa_config)
    end

    def re_pull_setup_data(credential)
      flash[:notice] = "Setting up your information."
      psa_config.update(credential: credential) unless psa_config.persisted?
      ServiceRunnerJob.perform_later("Integrations::InitializePsaConfig::RePullSetupData",
                                     credential.type.split("::").last,
                                     credential,
                                     psa_config)
    end
  end
end
