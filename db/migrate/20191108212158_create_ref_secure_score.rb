class CreateRefSecureScore < ActiveRecord::Migration[5.2]
  def change
    create_table :ref_secure_scores, id: :string do |t|
      t.boolean :scored
      t.boolean :deprecated
      t.float   :max_score
      t.jsonb   :details

      t.timestamps
    end
  end
end
