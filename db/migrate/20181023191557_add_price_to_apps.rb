class AddPriceToApps < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_monetize :apps, :price
    end
  end
end
