class AddBillingDetailsToProvider < ActiveRecord::Migration[5.0]
  def change
    add_column :providers, :contact_name, :string
    add_column :providers, :street_1, :string
    add_column :providers, :street_2, :string
    add_column :providers, :city, :string
    add_column :providers, :state, :string
    add_column :providers, :country, :string, default: "United States of America"
    add_column :providers, :zip_code, :string
  end
end
