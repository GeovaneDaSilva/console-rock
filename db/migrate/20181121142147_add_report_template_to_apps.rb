class AddReportTemplateToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :report_template, :integer
    change_column_default :apps, :report_template, from: nil, to: 0
  end
end
