# :nodoc
class Office365sController < AuthenticatedController
  include Pagy::Backend

  helper_method :all_secure_score_results, :ref_scores_paged, :affected_customers, :user_list_paged

  def show
    authorize current_account, :office365_apps_enabled_in_tree?

    @graph_json = { result: graph_secure_scores }.to_json
    @all_secure_score_results_size = secure_score_results.size
    @total_users = user_list.size

    @user_list_pagination, @user_list = paginate_user_list
    @ref_scores_pagination, @ref_scores = paginate_ref_scores
    @secure_score_results_pagination, @secure_score_results = paginate_secure_score_results
  end

  private

  def affected_customers(result)
    result.app_results.where(app: secure_score)
          .where("account_path <@ ?", current_account.path)
          .where("details->'score' < ?", result.max_score.to_s).size
  end

  def paginate_secure_score_results
    pagy secure_score_results, page_param: :secure_score_results, items: 8
  end

  def graph_secure_scores
    Rails.cache.fetch(["v1/graph_secure_scores", graph_secure_score], expires_in: 1.hour) do
      graph_secure_score.collect do |item|
        score = ((item[:details]["currentScore"] / item[:details]["maxScore"]) * 100).round(2)
        {
          customer: item.customer.name,
          score:    score,
          date:     item.detection_date.strftime("%m/%d")
        }
      end
    end
  end

  def graph_secure_score
    @graph_secure_score ||= current_account.all_descendant_office365_results
                                           .where(app: secure_score, value: "overallScore")
                                           .includes(:customer)
                                           .order(:detection_date)
                                           .limit(1_000)
  end

  def secure_score_results
    @secure_score_results ||=
      current_account.all_descendant_office365_results
                     .joins(:ref_secure_scores)
                     .where(app: secure_score)
                     .includes(:ref_secure_scores)
                     .order(
                       Arel.sql("ref_secure_scores.max_score desc, customer_id")
                     )
  end

  def result_scope
    current_account.all_descendant_office365_results
                   .where(app: secure_score)
                   .where.not(value: "overallScore")
                   .pluck(:value)
  end

  def ref_scores
    @ref_scores ||= RefSecureScore.where(id: result_scope)
                                  .order(Arel.sql("max_score desc, id"))
  end

  def paginate_ref_scores
    pagy ref_scores, page_param: :ref_scores, items: 8
  end

  def secure_score
    @secure_score ||= App.where(report_template: "secure_score").first
  end

  def user_list
    @user_list ||= current_account.all_descendant_billable_instances
                                  .office_365_mailbox
                                  .active
                                  .order(:account_path, :external_id)
  end

  def paginate_user_list
    pagy user_list, page_param: :user_list, items: 10
  end
end
