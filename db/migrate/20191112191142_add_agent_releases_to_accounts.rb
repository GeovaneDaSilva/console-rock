class AddAgentReleasesToAccounts < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :accounts, :agent_release_id, :string
    add_column :accounts, :agent_release_group, :integer

    change_column_default :accounts, :agent_release_group, from: nil, to: 0
    change_column_default :accounts, :agent_release_id, from: nil, to: ""

    add_index :accounts, :agent_release_id, algorithm: :concurrently

    reversible do |dir|
      dir.up do
        Account.update_all(agent_release_group: 0, agent_release_id: "")
      end
    end
  end
end
