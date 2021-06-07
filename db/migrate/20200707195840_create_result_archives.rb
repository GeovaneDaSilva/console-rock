class CreateResultArchives < ActiveRecord::Migration[5.2]
  def change
    create_table :result_archives do |t|
      t.string    :upload_id, index: true
      t.integer   :customer_id, index: true
      t.datetime  :start_time
      t.datetime  :end_time

      t.timestamps
    end
  end
end
