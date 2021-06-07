# Records of deleted customers
class DeletedCustomer < ApplicationRecord
  def agent_release_id; end

  def setting
    @setting ||= Setting.new
  end
end
