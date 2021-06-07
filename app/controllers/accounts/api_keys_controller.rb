module Accounts
  # Modify account api keys
  class ApiKeysController < AuthenticatedController
    def create
      authorize account, :can_generate_api_keys?

      api_key = ApiKey.new(api_key_params)

      if api_key.save
        flash[:notice] = "Success"
      else
        flash[:error] = "Unable to add generate API key"
      end

      redirect_to account_path(account, anchor: "api")
    end

    def update
      authorize account, :can_generate_api_keys?

      api_key = ApiKey.find(params[:id])
      api_key.assign_attributes(params.require(:api_key).permit(:allow_moving_info))
      saved = api_key.save

      account.move_codes.create(expiration: 2.weeks.from_now) if api_key.allow_moving_info && saved

      redirect_to account_path(account, anchor: "api")
    end

    def destroy
      authorize account, :can_generate_api_keys?

      api_key = ApiKey.find_by(account_id: params[:account_id])

      if api_key.destroy
        flash[:notice] = "API key removed"
      else
        flash[:error] = "Unable to remove API key"
      end

      redirect_to account_path(account, anchor: "api")
    end

    private

    def account
      @account ||= Account.find(params[:account_id])
    end

    def api_key_params
      {
        user_id:    current_user&.id,
        account_id: params[:account_id]
      }
    end
  end
end
