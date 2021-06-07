class RemoveDisableChatColumnFromAccounts < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :accounts, :disable_chat_support
    end
  end
end
