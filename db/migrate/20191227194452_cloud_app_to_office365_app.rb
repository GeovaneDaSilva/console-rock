class CloudAppToOffice365App < ActiveRecord::Migration[5.2]
  def up
    App.reset_column_information
    Apps::CloudResult.reset_column_information

    App.where(type: "Apps::CloudApp").update_all(type: "Apps::Office365App")
    Apps::Result.where(type: "Apps::CloudResult").update_all(type: "Apps::Office365Result")
  end

  def down
    App.reset_column_information
    Apps::CloudResult.reset_column_information

    App.where(type: "Apps::Office365App").update_all(type: "Apps::CloudApp")
    Apps::Result.where(type: "Apps::Office365Result").update_all(type: "Apps::CloudResult")
  end
end
