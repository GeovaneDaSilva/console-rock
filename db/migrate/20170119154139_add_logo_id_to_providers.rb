class AddLogoIdToProviders < ActiveRecord::Migration[5.0]
  def change
    # One way reference to a specific upload, no index needed
    # Provider -> Upload.find_by(id: logo_id)
    add_column :providers, :logo_id, :uuid
  end
end
