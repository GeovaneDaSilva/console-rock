module Uploads
  # Uploads associated with a provider object
  class ProviderUploadsController < AuthenticatedController
    include Uploadable

    before_action :find_provider, only: %i[create update show destroy]

    # Override default action
    def destroy
      authorize @upload

      @upload.trashed!
      @provider.update(logo: nil)

      head :ok
    end

    private

    def create_upload!
      authorize @provider, :edit?

      @upload = @provider.uploads.create(upload_params)
    end

    def upload_url
      uploads_provider_upload_url(@provider, @upload,
                                  host: ENV.fetch(I18n.t("application.host"), ENV["HOST"]))
    end

    def find_provider
      @provider ||= Provider.find(params[:provider_id])
    end
  end
end
