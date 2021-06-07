class CreateActionTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :action_templates do |t|
      t.string   :name, null: false
      t.jsonb    :details, default: {}
      t.string   :type

      t.timestamps
    end
  end
end
