module Administration
  # :nodoc
  class SystemHuntsCategoriesController < BaseController
    include Pagy::Backend

    before_action :category, except: %i[index new create]

    def index
      @pagination, @system_hunts_categories = pagy SystemHunts::Category
    end

    def show; end

    def new
      @category = SystemHunts::Category.new
    end

    def edit; end

    def create
      @category = SystemHunts::Category.new(category_params)

      if @category.save
        flash[:notice] = "Created category"
        redirect_to administration_system_hunts_category_path(category)
      else
        flash.now[:error] = "Unable to create category"
        render :new
      end
    end

    def update
      if category.update(category_params)
        flash[:notice] = "Updated category"
        redirect_to administration_system_hunts_category_path(category)
      else
        flash.now[:error] = "Unable to update category"
        render :edit
      end
    end

    def destroy
      if category.destroy
        flash[:notice] = "Category deleted"
        redirect_to administration_system_hunts_categories_path
      else
        flash[:error] = "Unable to delete category"
        redirect_to administration_system_hunts_category_path(category)
      end
    end

    private

    def category
      @category ||= SystemHunts::Category.find(params[:id])
    end

    def category_params
      params.require(:system_hunts_category).permit(:name, :description)
    end
  end
end
