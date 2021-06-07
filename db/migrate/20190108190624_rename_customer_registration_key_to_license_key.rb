class RenameCustomerRegistrationKeyToLicenseKey < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_column :accounts, :registration_key, :license_key
    end
  end
end
