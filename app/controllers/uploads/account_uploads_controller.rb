module Uploads
  # Uploads associated with a Account object
  class AccountUploadsController < AuthenticatedController
    include Uploadable

    private

    def account
      @account ||= Account.find(params[:account_id])
    end

    def create_upload!
      authorize account, :edit?

      @upload = account.uploads.create(upload_params)
    end

    def upload_url
      uploads_account_upload_url(account, @upload, host: ENV.fetch(I18n.t("application.host"), ENV["HOST"]))
    end
  end
end
