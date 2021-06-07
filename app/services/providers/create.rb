module Providers
  # Small service to create new Providers after User creation on sign up
  class Create
    def initialize(user)
      @user = user
    end

    def call
      provider.save!

      provider.user_roles.create(
        user: @user
      )

      turn_on_default_apps!

      ServiceRunnerJob.perform_later("Braintree::CustomerBuilder", provider)
      AdministrationMailer.new_account(provider).deliver_later
    end

    private

    def provider
      @provider ||= Provider.new(name: @user.new_provider_name)
    end

    def turn_on_default_apps!
      App.where(on_by_default: true).each do |app|
        AccountApp.create(app: app, account: provider, enabled_at: Time.current)
      end
    end
  end
end
