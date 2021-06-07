class AddDetectionDateToGeocodedThreats < ActiveRecord::Migration[5.2]
  def change
    add_column :geocoded_threats, :detection_date, :datetime
  end
end
