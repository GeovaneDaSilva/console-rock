module Administration
  # Admin views for providers
  class ProvidersController < Administration::BaseController
    include Pagy::Backend

    def index
      authorize(:administration, :view_providers?)
      filter = ::Filters::Administration::ProviderFilter.new(filter_params)

      @pagination, @providers = pagy filter.filter, items: 10
    end

    def new
      authorize(:administration, :provision_providers?)
    end

    def create
      authorize(:administration, :provision_providers?)
      user = invite_user!

      rocketcyber_trial_id = Plan.where(plan_type: "rocketcyber", trial: true).first.id
      provider = Provider.new(name: params[:provider_name], plan_id: rocketcyber_trial_id)

      if user&.persisted? && provider.save
        flash[:notice] = "Account successfully provisioned"
        session[:account_id] = provider.id

        setup_provider!(provider, user)

        redirect_to provider_path(provider)
      elsif !user&.persisted?
        flash[:error] = "Unable to provision account, invalid user"
        redirect_to new_administration_provider_path
      else
        flash[:error] = "Unable to to provision account"
        redirect_to new_administration_provider_path
      end
    end

    def destroy
      provider = Provider.find(params[:id])

      authorize provider

      respond_to do |format|
        format.js do
          @job_id = PolledTaskRunner.new.call(
            "Accounts::Destroyer", provider
          ).key.split("/").last

          @result_path = administration_providers_path
          render "customers/destroy"
        end
      end
    end

    private

    def setup_provider!(provider, user)
      Subscriptions::Email.create(
        account: provider, event_types: [:malicious_indicator], email_address: user.email
      )

      ServiceRunnerJob.perform_later("Providers::FeedSubscriber", provider)
      ServiceRunnerJob.perform_later("Braintree::CustomerBuilder", provider)

      add_demo_customer_data!(provider) if params[:add_demo_customer_data] == "1"
      add_user_to_provider!(user, provider)
      turn_on_default_apps!(provider)
    end

    def filter_params
      params.permit(:search, :payment_status, :plan_id, :status, :agent_release_group, :page)
    end

    def turn_on_default_apps!(provider)
      App.where(on_by_default: true).each do |app|
        AccountApp.create(app: app, account: provider, enabled_at: Time.current)
      end
    end

    def invite_user!
      UserInvitor.new(
        params[:email],
        "#{params[:first_name]} #{params[:last_name]}",
        current_user,
        params[:send_invitation_email] != "1"
      ).call
    end

    def add_demo_customer_data!(provider)
      ServiceRunnerJob.perform_later("Seed::Provider", provider)
    end

    def add_user_to_provider!(user, provider)
      provider.user_roles.create(
        user: user, role: :owner
      )
    end
  end
end
