module Uploads
  # Uploads associated with a support file
  class SystemHuntFileUploadsController < AuthenticatedController
    include Uploadable

    private

    def create_upload!
      authorize(:administration, :manage_system_hunts?)

      @upload = current_user.uploads.create(upload_params)
    end

    def upload_url
      uploads_system_hunt_file_upload_url(@upload, host: ENV.fetch(I18n.t("application.host"), ENV["HOST"]))
    end

    def upload_params_keys
      super.push(:protected)
    end

    def filesize
      0..200.megabytes
    end

    def acl
      "private"
    end
  end
end
