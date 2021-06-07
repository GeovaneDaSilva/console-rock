module Uploads
  # Destroy trashed uploads
  class Destroyer
    def initialize(upload)
      @upload = upload.reload
    rescue ActiveRecord::RecordNotFound
      @upload = nil
    end

    def call
      return unless @upload&.trashed?

      @upload.object.delete
      @upload.destroy
    end
  end
end
