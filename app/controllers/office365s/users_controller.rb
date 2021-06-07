# :nodoc
module Office365s
  # Search UI for finding accounts
  class UsersController < AuthenticatedController
    include Pagy::Backend

    helper_method :billed_users_paged, :not_billed_users_paged

    def show
      authorize current_account, :office365_apps_enabled_in_tree?

      @total_billed_users = billed_users.size
      @total_not_billed_users = not_billed_users.size

      @billed_users_pagination, @billed_users = paginate_billed_users
      @not_billed_users_pagination, @not_billed_users = paginate_not_billed_users
    end

    def update
      authorize current_account, :office365_apps_enabled_in_tree?

      if params[:add]
        not_billed_users.find(params[:users]).each do |one_user|
          one_user.update(active: true)
        end
      elsif params[:remove]
        billed_users.find(params[:users]).each do |one_user|
          one_user.update(active: false)
        end
        ServiceRunnerJob.perform_later("UpdateReports::BillableInstance", params[:users])
      end

      redirect_back fallback_location: account_office365_path, turbolinks: :advance
    end

    private

    def billed_users
      @billed_users ||= users.where(active: true).order(:external_id)
    end

    def paginate_billed_users
      pagy billed_users, page_param: :billed_users, items: 20
    end

    def not_billed_users
      @not_billed_users ||= users.where(active: false).order(:external_id)
    end

    def paginate_not_billed_users
      pagy not_billed_users, page_param: :not_billed_users, items: 20
    end

    def users
      @users ||= current_account.all_descendant_billable_instances.where(line_item_type: "office_365_mailbox")
    end
  end
end
