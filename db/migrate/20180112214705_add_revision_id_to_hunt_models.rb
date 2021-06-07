class AddRevisionIdToHuntModels < ActiveRecord::Migration[5.1]
  def change
    add_column :hunts, :revision_id, :string, unique: true, index: true
    add_column :hunt_results, :hunt_revision_id, :string, index: true

    reversible do |dir|
      dir.up do
        Hunt.reset_column_information
        HuntResult.reset_column_information

        Hunt.find_each { |hunt| hunt.update(revision_id: [hunt.id, hunt.revision].join("-")) }
        HuntResult.find_each { |hr| hr.update(hunt_revision_id: [hr.hunt_id, hr.revision].join("-")) }
      end
    end
  end
end
