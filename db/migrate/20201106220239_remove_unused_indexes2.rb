class RemoveUnusedIndexes2 < ActiveRecord::Migration[5.2]
  def change
    remove_index :apps_results, name: "index_apps_results_on_incident"
    remove_index :accounts, name: "index_accounts_on_tenant_id"
    remove_index :devices, name: "index_devices_on_mac_address"
    remove_index :crash_reports, name: "index_crash_reports_on_upload_id"
    remove_index :apps_results, name: "index_apps_results_on_account_path_where_app_id_1"
    remove_index :account_apps, name: "index_account_apps_on_last_pull"
    remove_index :result_archives, name: "index_result_archives_on_upload_id"
    remove_index :credentials, name: "index_credentials_on_expiration"
    remove_index :apps_incidents, name: "index_apps_incidents_on_resolver_id"
    remove_index :apps_incidents, name: "index_apps_incidents_on_creator_id"
    remove_index :charges, name: "index_charges_on_provider_id"
    remove_index :charges, name: "index_charges_on_braintree_transaction_id"
    remove_index :remediation_plans, name: "index_remediation_plans_on_account_path"
    remove_index :users, name: "index_users_on_invited_by_type_and_invited_by_id"
    remove_index :users, name: "index_users_on_invited_by_id"
    remove_index :agent_releases, name: "index_agent_releases_on_creator_id"
    remove_index :analyses, name: "index_analyses_on_account_id"
    remove_index :analyses, name: "index_analyses_on_type"
    remove_index :analyses, name: "index_analyses_on_user_id"
    remove_index :api_keys, name: "index_api_keys_on_access_token"
    remove_index :apps, name: "index_apps_on_display_image_icon_id"
    remove_index :apps, name: "index_apps_on_display_image_id"
    remove_index :apps, name: "index_apps_on_upload_id"
    remove_index :logic_rules, name: "index_logic_rules_on_account_path"
    remove_index :logic_rules, name: "index_logic_rules_on_user_id"
    remove_index :plan_apps, name: "index_plan_apps_on_app_id"
    remove_index :plan_apps, name: "index_plan_apps_on_plan_id"
    remove_index :apps_results, name: "index_apps_results_on_account_path_where_app_id_13"
    remove_index :apps_results, name: "index_apps_results_on_account_path_where_app_id_14"
    remove_index :apps_results, name: "index_apps_results_on_account_path_where_app_id_15"
    remove_index :apps_results, name: "index_apps_results_on_account_path_where_app_id_16"
    remove_index :apps_results, name: "index_apps_results_on_account_path_where_app_id_17"
    remove_index :apps_results, name: "index_apps_results_on_device_id"
    remove_index :apps_results, name: "index_apps_results_on_type_and_device_id"
    remove_index :devices_device_logs, name: "index_devices_device_logs_on_customer_id"
    remove_index :devices_device_logs, name: "index_devices_device_logs_on_device_id"
    remove_index :devices_device_logs, name: "index_devices_device_logs_on_upload_id"
    remove_index :plan_transitions, name: "index_plan_transitions_on_from_plan"
    remove_index :report_accounts, name: "index_report_accounts_on_account_id"
    remove_index :report_app_results, name: "index_report_app_results_on_app_id"
    remove_index :report_app_results, name: "index_report_app_results_on_verdict"
    remove_index :report_billable_instances, name: "index_report_billable_instances_on_billable_instance_id"
    remove_index :report_devices, name: "index_report_devices_on_device_id"
    remove_index :report_incidents, name: "index_report_incidents_on_incident_id"
  end
end
