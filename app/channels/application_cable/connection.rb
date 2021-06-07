module ApplicationCable
  # :nodoc
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_current_user
    end

    private

    def find_current_user
      User.find_by!(id: cookies.signed[:user_id])
    rescue ActiveRecord::RecordNotFound
      reject_unauthorized_connection
    end
  end
end
