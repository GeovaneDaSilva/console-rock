class AddChatSupportToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :disable_chat_support, :boolean
  end
end
