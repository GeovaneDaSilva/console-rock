class AddStartAndEndDatesToCharges < ActiveRecord::Migration[5.0]
  def change
    add_column :charges, :start_date, :datetime
    add_column :charges, :end_date, :datetime

    Charge.reset_column_information

    # This doesn't need to be accurate since these are new columns anyway, and plans which use
    # them don't exist yet
    Charge.update_all(start_date: DateTime.current.beginning_of_day, end_date: DateTime.current.end_of_day)
  end
end
