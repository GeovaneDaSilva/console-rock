module Uploads
  # Uploads associated with a support file
  class SupportFileUploadsController < AuthenticatedController
    include Uploadable

    # Override default action
    def destroy
      authorize(:administration, :modify_support_files?)

      @upload.trashed!

      redirect_to administration_support_files_path
    end

    private

    def create_upload!
      authorize(:administration, :modify_support_files?)

      @upload = current_user.uploads.create(upload_params.merge(support_file: true))
    end

    def upload_url
      uploads_support_file_upload_url(@upload, host: ENV.fetch(I18n.t("application.host"), ENV["HOST"]))
    end

    def upload_params_keys
      super.push(:protected)
    end

    def filesize
      0..200.megabytes
    end

    def acl
      params[:protected].blank? ? "public-read" : "private"
    end
  end
end
