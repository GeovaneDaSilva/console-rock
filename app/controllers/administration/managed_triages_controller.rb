module Administration
  # :nodoc
  class ManagedTriagesController < BaseController
    include Pagy::Backend

    helper_method :managed_accounts, :accounts_with_results

    def show
      authorize :administration, :managed_triage?

      @pagination, @managed_accounts = pagy managed_accounts, items: 5
    end

    private

    def apps
      @apps ||= App.all.load
    end

    def managed_accounts
      paged_shortlist
    end

    def accounts_with_results
      @accounts_with_results ||= Account.where("paid_thru > ?", DateTime.current.beginning_of_day)
                                        .joins(:plan).where(plans: { managed: true })
                                        .joins(
                                          <<~SQL
                                            LEFT OUTER JOIN apps_counter_caches
                                            ON apps_counter_caches.account_path <@ accounts.path
                                          SQL
                                        )
                                        .where("apps_counter_caches.count > 0")
                                        .joins("INNER JOIN apps on apps_counter_caches.app_id = apps.id")
                                        .select("accounts.*, apps.title, apps.id as app_id")
    end

    def paged_shortlist
      @paged_shortlist ||= Account.where(id: accounts_with_results.uniq.pluck(:id)).order(:name)
    end
  end
end
