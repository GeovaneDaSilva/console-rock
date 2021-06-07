# :nodoc
module AccountsHelper
  def sales_stale
    Accounts::SalesInfoGenerator.new.stale_info
  end

  def sales_general
    Accounts::SalesInfoGenerator.new.general_info
  end
end
