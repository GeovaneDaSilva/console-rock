class UpdatePlansToControlThreatHuntingAndAdvancedThreatHunting < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_column :plans, :advanced_hunting, :boolean, default: true
      remove_column :plans, :continuous_hunting, :boolean, default: true
    end

    add_column :plans, :threat_hunting, :boolean
    add_column :plans, :threat_intel_feeds, :boolean

    change_column_default :plans, :threat_hunting, from: nil, to: true
    change_column_default :plans, :threat_intel_feeds, from: nil, to: true
  end
end
