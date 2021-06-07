module Administration
  # Admin views for moving customers between providers
  class MoveCustomersController < Administration::BaseController
    include Pagy::Backend

    helper_method :customers, :customer, :providers

    def index
      authorize :administration, :move_customers?

      @pagination, @customers = pagy customers
    end

    def edit
      authorize :administration, :move_customers?

      @pagination, @providers = pagy providers
    end

    def update
      authorize :administration, :move_customers?
      prior_provider = customer.parent

      if customer.update(path: selected_provider.path)
        flash[:notice] = "Moved #{customer.name} from #{prior_provider.name} to #{selected_provider.name}"
      else
        flash[:error] = "Unable to move #{customer.name} to #{selected_provider.name}"
      end

      redirect_to administration_move_customers_path
    end

    private

    def selected_provider
      Provider.find(params[:provider_id])
    end

    def customer
      @customer ||= Customer.find(params[:id])
    end

    def customers
      @customers ||= if params[:search]
                       Customer.where("name ILIKE ?", "%#{params[:search]}%")
                     else
                       Customer.all
                     end
    end

    def providers
      @providers ||= if params[:search]
                       Provider.where("name ILIKE ?", "%#{params[:search]}%")
                     else
                       Provider.all
                     end
    end
  end
end
