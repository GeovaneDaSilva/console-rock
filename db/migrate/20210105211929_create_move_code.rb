class CreateMoveCode < ActiveRecord::Migration[5.2]
  def change
    create_table :move_codes, id: :uuid do |t|
      t.integer   :account_id
      t.datetime  :expiration
    end
  end
end
