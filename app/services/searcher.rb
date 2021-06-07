# Search scoped to a user
# Search within the context of a user and an account
# Supports searching by provider or customer objects, devices will be scoped
# to that account instance
# Be efficient and speicify which indexes to search for, all by default
class Searcher
  def initialize(query, user, account: nil, search_for: nil)
    @query      = query.presence || ""
    @user       = user
    @account    = account
    @search_for = search_for || %w[Device Provider Customer Group]
  end

  def call
    return TextSearch.none unless @user # Don't return searches for non-authenticated users

    sql_query = TextSearch.where(searchable_type: @search_for)
    sql_query = sql_query.where(account_id: account_ids) unless @user.admin?

    return sql_query if @query.blank?

    sql_query.fuzzy_search(@query.downcase)
  end

  private

  def account_ids
    @account&.self_and_all_descendants&.pluck(:id) || @user.account_ids
  end
end
