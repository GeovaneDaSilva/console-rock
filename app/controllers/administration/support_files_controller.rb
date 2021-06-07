module Administration
  # Admin views for providers
  class SupportFilesController < Administration::BaseController
    include Pagy::Backend

    def index
      authorize(:administration, :view_support_files?)
      @support_files = Upload.support_files.includes(:sourceable)
                             .reorder("created_at DESC")
                             .where("filename LIKE ?", "%#{params[:search]}%")
      @pagination, @support_files = pagy @support_files, items: 25
    end
  end
end
