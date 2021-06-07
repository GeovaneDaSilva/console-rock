# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_05_06_205532) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "ltree"
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "account_apps", force: :cascade do |t|
    t.integer "account_id"
    t.integer "app_id"
    t.datetime "disabled_at"
    t.datetime "enabled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "config", default: {}
    t.datetime "last_pull"
    t.index ["account_id"], name: "index_account_apps_on_account_id"
    t.index ["app_id"], name: "index_account_apps_on_app_id"
  end

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.ltree "path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "logo_id"
    t.string "contact_name"
    t.string "street_1"
    t.string "street_2"
    t.string "city"
    t.string "state"
    t.string "country", default: "United States of America"
    t.string "zip_code"
    t.integer "plan_id"
    t.date "paid_thru"
    t.integer "status", default: 0, null: false
    t.string "card_type"
    t.string "card_masked_number"
    t.string "card_payment_method_token"
    t.string "type", default: "Provider"
    t.string "license_key"
    t.boolean "demo", default: false, null: false
    t.boolean "marked_for_deletion", default: false, null: false
    t.jsonb "api_keys"
    t.integer "onboarding", default: 0
    t.datetime "incident_report_email_last_sent"
    t.string "braintree_customer_id"
    t.boolean "beta_apps", default: false
    t.text "emails"
    t.boolean "disable_sub_subscriptions", default: true
    t.string "tenant_id"
    t.string "agent_release_id", default: ""
    t.integer "agent_release_group", default: 0
    t.boolean "enable_customer_notifications"
    t.index ["agent_release_id"], name: "index_accounts_on_agent_release_id"
    t.index ["license_key"], name: "index_accounts_on_license_key"
    t.index ["path"], name: "index_accounts_on_path", using: :gist
    t.index ["plan_id"], name: "index_accounts_on_plan_id"
    t.index ["type", "id"], name: "index_accounts_on_type_and_id"
  end

  create_table "action_templates", force: :cascade do |t|
    t.string "name", null: false
    t.jsonb "details", default: {}
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "agent_releases", id: :string, force: :cascade do |t|
    t.integer "period", default: 1800, null: false
    t.text "description", null: false
    t.integer "creator_id", null: false
    t.integer "agent_release_groups", default: [], null: false, array: true
    t.text "upload_ids", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "analyses", force: :cascade do |t|
    t.jsonb "resource"
    t.string "type"
    t.integer "status", default: 0, null: false
    t.bigint "user_id"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "antivirus_customer_maps", force: :cascade do |t|
    t.integer "account_id"
    t.string "antivirus_id"
    t.integer "app_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "api_keys", force: :cascade do |t|
    t.string "access_token", null: false
    t.string "refresh_token"
    t.integer "account_id", null: false
    t.datetime "expiration"
    t.text "permissions", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.boolean "allow_moving_info", default: false
    t.index ["account_id"], name: "index_api_keys_on_account_id"
  end

  create_table "apps", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.string "upload_id"
    t.integer "indicator", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "USD", null: false
    t.integer "report_template", default: 0
    t.string "display_image_id"
    t.string "display_image_icon_id"
    t.boolean "on_by_default"
    t.integer "configuration_type"
    t.integer "author", default: 0
    t.boolean "disabled", default: false
    t.boolean "beta", default: false
    t.string "type"
    t.boolean "discreet", default: false
    t.text "platforms", default: [], array: true
    t.text "configuration_scopes", default: [], array: true
    t.text "additional_types", default: [], array: true
    t.index ["disabled"], name: "index_apps_on_disabled"
    t.index ["discreet"], name: "index_apps_on_discreet"
  end

  create_table "apps_configs", force: :cascade do |t|
    t.integer "app_id"
    t.json "config"
    t.string "device_id"
    t.integer "account_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_apps_configs_on_app_id"
    t.index ["type", "account_id"], name: "index_apps_configs_on_type_and_account_id"
    t.index ["type", "device_id"], name: "index_apps_configs_on_type_and_device_id"
  end

  create_table "apps_counter_caches", force: :cascade do |t|
    t.ltree "account_path", null: false
    t.integer "app_id", null: false
    t.integer "count", default: 0, null: false
    t.integer "verdict", null: false
    t.string "device_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_path"], name: "index_apps_counter_caches_on_account_path", using: :gist
    t.index ["app_id"], name: "index_apps_counter_caches_on_app_id"
    t.index ["device_id"], name: "index_apps_counter_caches_on_device_id", where: "(device_id IS NOT NULL)"
    t.index ["verdict"], name: "index_apps_counter_caches_on_verdict"
  end

  create_table "apps_incidents", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.text "remediation"
    t.ltree "account_path", null: false
    t.integer "state", default: 0, null: false
    t.integer "creator_id", null: false
    t.integer "resolver_id"
    t.datetime "resolved_at"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "psa_id"
    t.integer "logic_rule_id"
    t.index ["account_path"], name: "index_apps_incidents_on_account_path", using: :gist
    t.index ["created_at"], name: "index_apps_incidents_on_created_at"
    t.index ["state"], name: "index_apps_incidents_on_state"
  end

  create_table "apps_results", force: :cascade do |t|
    t.integer "app_id", null: false
    t.string "device_id"
    t.integer "verdict", default: 0, null: false
    t.datetime "detection_date", null: false
    t.text "value", null: false
    t.string "value_type", null: false
    t.jsonb "details", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "incident"
    t.string "confidence"
    t.integer "action_state"
    t.jsonb "action_result", default: {}
    t.string "type"
    t.integer "customer_id", null: false
    t.ltree "account_path"
    t.integer "counter_cache_id"
    t.integer "incident_id"
    t.string "external_id"
    t.integer "credential_id"
    t.integer "archive_state", default: 0
    t.index "((((details -> 'attributes'::text) -> 'user'::text) ->> 'principalName'::text))", name: "idx_on_apps_results_details_attributes_user_principalname", where: "((((details -> 'attributes'::text) -> 'user'::text) ->> 'principalName'::text) IS NOT NULL)"
    t.index "(((details -> 'attributes'::text) ->> 'country'::text))", name: "idx_on_apps_results_details_attributes_country", where: "(((details -> 'attributes'::text) ->> 'country'::text) IS NOT NULL)"
    t.index "((details ->> 'type'::text))", name: "index_apps_results_details_type"
    t.index ["account_path"], name: "index_apps_results_on_account_path", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_10", where: "(app_id = 10)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_11", where: "(app_id = 11)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_12", where: "(app_id = 12)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_18", where: "(app_id = 18)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_19", where: "(app_id = 19)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_2", where: "(app_id = 2)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_20", where: "(app_id = 20)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_21", where: "(app_id = 21)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_22", where: "(app_id = 22)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_23", where: "(app_id = 23)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_24", where: "(app_id = 24)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_3", where: "(app_id = 3)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_4", where: "(app_id = 4)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_5", where: "(app_id = 5)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_6", where: "(app_id = 6)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_60", where: "(app_id = 60)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_61", where: "(app_id = 61)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_62", where: "(app_id = 62)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_63", where: "(app_id = 63)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_64", where: "(app_id = 64)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_65", where: "(app_id = 65)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_7", where: "(app_id = 7)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_8", where: "(app_id = 8)", using: :gist
    t.index ["account_path"], name: "index_apps_results_on_account_path_where_app_id_9", where: "(app_id = 9)", using: :gist
    t.index ["app_id", "device_id"], name: "index_apps_results_on_app_id_and_device_id"
    t.index ["archive_state"], name: "index_apps_results_on_archive_state"
    t.index ["counter_cache_id"], name: "index_apps_results_on_counter_cache_id"
    t.index ["credential_id"], name: "index_apps_results_on_credential_id"
    t.index ["customer_id", "app_id", "detection_date"], name: "idx_apps_results_on_customer_id_app_id_detection_date_desc", order: { detection_date: :desc }, where: "(incident_id IS NULL)"
    t.index ["customer_id"], name: "index_apps_results_on_customer_id"
    t.index ["detection_date", "app_id", "incident_id"], name: "idx_on_apps_results_improve_triages_show_speed", order: { detection_date: :desc }
    t.index ["detection_date"], name: "index_apps_results_on_detection_date"
    t.index ["device_id", "verdict"], name: "index_apps_results_on_device_id_and_verdict"
    t.index ["external_id"], name: "index_apps_results_on_external_id"
    t.index ["incident_id"], name: "index_apps_results_on_incident_id"
    t.index ["type"], name: "index_apps_results_on_type"
    t.index ["value", "value_type"], name: "index_apps_results_on_value_and_value_type"
    t.index ["verdict"], name: "index_apps_results_on_verdict"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "billable_instances", force: :cascade do |t|
    t.ltree "account_path", null: false
    t.jsonb "details", default: {}
    t.string "external_id", null: false
    t.integer "line_item_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.index ["account_path"], name: "index_billable_instances_on_account_path", using: :gist
    t.index ["active"], name: "index_billable_instances_on_active", where: "(active = true)"
    t.index ["external_id"], name: "index_billable_instances_on_external_id"
    t.index ["line_item_type"], name: "index_billable_instances_on_line_item_type"
    t.index ["updated_at"], name: "index_billable_instances_on_updated_at"
  end

  create_table "charges", id: :serial, force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.integer "provider_id"
    t.integer "plan_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "card_type"
    t.string "card_masked_number"
    t.string "braintree_transaction_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "account_id"
    t.index ["account_id"], name: "index_charges_on_account_id"
    t.index ["plan_id"], name: "index_charges_on_plan_id"
  end

  create_table "crash_reports", force: :cascade do |t|
    t.string "device_id", null: false
    t.string "upload_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_crash_reports_on_device_id"
  end

  create_table "credentials", force: :cascade do |t|
    t.string "tenant_id"
    t.integer "customer_id"
    t.string "display_name"
    t.string "email"
    t.datetime "expiration"
    t.jsonb "keys"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.index ["account_id"], name: "index_credentials_on_account_id"
    t.index ["tenant_id"], name: "index_credentials_on_tenant_id"
    t.index ["type"], name: "index_credentials_on_type"
  end

  create_table "deleted_customers", force: :cascade do |t|
    t.string "license_key"
    t.jsonb "details", default: "{}"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["license_key"], name: "index_deleted_customers_on_license_key"
  end

  create_table "devices", id: :string, force: :cascade do |t|
    t.integer "customer_id"
    t.string "hostname"
    t.string "ipv4_address"
    t.string "mac_address"
    t.string "username"
    t.string "fingerprint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "timezone", default: "Etc/GMT+6"
    t.integer "egress_ip_id"
    t.string "ipv4_subnet_mask", default: "255.255.255.0", null: false
    t.string "network"
    t.datetime "group_attributes_cache_key"
    t.string "platform"
    t.string "family"
    t.string "version"
    t.string "edition"
    t.string "architecture"
    t.string "build"
    t.boolean "marked_for_deletion", default: false, null: false
    t.string "agent_version"
    t.integer "connectivity", default: 0, null: false
    t.datetime "connectivity_updated_at", default: "2008-12-05 00:03:27"
    t.datetime "last_connected_at"
    t.string "release"
    t.integer "suspicious_count", default: 0
    t.integer "malicious_count", default: 0
    t.integer "informational_count", default: 0
    t.integer "defender_health_status", default: 0
    t.text "uuid"
    t.datetime "inventory_last_updated_at"
    t.string "inventory_upload_id"
    t.ltree "account_path"
    t.integer "device_type"
    t.jsonb "details", default: {}
    t.index ["account_path"], name: "index_devices_on_account_path", using: :gist
    t.index ["customer_id"], name: "index_devices_on_customer_id"
    t.index ["egress_ip_id"], name: "index_devices_on_egress_ip_id"
    t.index ["marked_for_deletion"], name: "index_devices_on_marked_for_deletion"
    t.index ["uuid"], name: "index_devices_on_uuid"
  end

  create_table "devices_agent_logs", force: :cascade do |t|
    t.string "device_id"
    t.string "upload_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_devices_agent_logs_on_device_id"
    t.index ["upload_id"], name: "index_devices_agent_logs_on_upload_id"
  end

  create_table "devices_connectivity_logs", force: :cascade do |t|
    t.string "device_id", null: false
    t.datetime "connected_at", null: false
    t.datetime "disconnected_at", null: false
    t.integer "duration", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["connected_at"], name: "index_devices_connectivity_logs_on_connected_at"
    t.index ["device_id"], name: "index_devices_connectivity_logs_on_device_id"
  end

  create_table "devices_device_logs", force: :cascade do |t|
    t.string "device_id"
    t.integer "customer_id"
    t.string "upload_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "devices_queued_hunts", force: :cascade do |t|
    t.string "device_id"
    t.integer "hunt_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_devices_queued_hunts_on_device_id"
    t.index ["hunt_id", "device_id"], name: "index_devices_queued_hunts_on_hunt_id_and_device_id", unique: true
  end

  create_table "egress_ips", id: :serial, force: :cascade do |t|
    t.integer "customer_id", null: false
    t.string "ip", null: false
    t.float "latitude", default: 0.0
    t.float "longitude", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "devices_count", default: 0
    t.string "city"
    t.string "state"
    t.string "country"
    t.index ["ip"], name: "index_egress_ips_on_ip"
  end

  create_table "emails", force: :cascade do |t|
    t.integer "account_id"
    t.text "emails", default: [], array: true
    t.integer "category"
    t.index ["account_id", "category"], name: "index_emails_on_account_id_and_category"
  end

  create_table "firewall_counters", force: :cascade do |t|
    t.ltree "account_path", null: false
    t.integer "count", default: 0, null: false
    t.integer "firewall_type", null: false
    t.integer "count_type", null: false
    t.integer "billable_instance_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_path"], name: "index_firewall_counters_on_account_path", using: :gist
  end

  create_table "geocoded_threats", force: :cascade do |t|
    t.string "value", null: false
    t.string "threatable_type", null: false
    t.string "threatable_id", null: false
    t.string "city"
    t.string "country"
    t.float "latitude", null: false
    t.float "longitude", null: false
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "detection_date"
    t.index ["account_id"], name: "index_geocoded_threats_on_account_id"
    t.index ["threatable_type", "threatable_id"], name: "index_geocoded_threats_on_threatable_type_and_threatable_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "query"
    t.string "network"
    t.string "public_ip"
    t.integer "query_fields", default: 0, null: false
    t.string "name", null: false
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "family_version_and_edition"
    t.string "architecture"
    t.boolean "required"
    t.index ["account_id"], name: "index_groups_on_account_id"
  end

  create_table "hunt_results", force: :cascade do |t|
    t.integer "hunt_id"
    t.integer "revision", default: 1, null: false
    t.string "device_id", null: false
    t.string "upload_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.boolean "processed", default: false
    t.integer "test_results_count", default: 0, null: false
    t.integer "result", default: 0, null: false
    t.boolean "archived", default: false
    t.string "hunt_revision_id"
    t.boolean "manually_run", default: false
    t.text "tags", default: [], array: true
    t.ltree "account_path"
    t.index ["account_path"], name: "index_hunt_results_on_account_path", using: :gist
    t.index ["created_at"], name: "index_hunt_results_on_created_at"
    t.index ["device_id"], name: "index_hunt_results_on_device_id"
    t.index ["hunt_id", "hunt_revision_id"], name: "index_hunt_results_on_hunt_id_and_hunt_revision_id"
    t.index ["upload_id"], name: "index_hunt_results_on_upload_id"
  end

  create_table "hunts", force: :cascade do |t|
    t.string "name"
    t.integer "group_id", null: false
    t.boolean "continuous", default: false, null: false
    t.integer "revision", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "feed_result_id"
    t.integer "matching", default: 0, null: false
    t.string "revision_id"
    t.boolean "disabled", default: false
    t.text "description"
    t.boolean "on_by_default", default: false
    t.integer "category_id"
    t.integer "indicator", default: 0
    t.boolean "on_demand"
    t.index ["category_id"], name: "index_hunts_on_category_id"
    t.index ["continuous"], name: "index_hunts_on_continuous"
    t.index ["disabled"], name: "index_hunts_on_disabled"
    t.index ["feed_result_id"], name: "index_hunts_on_feed_result_id"
    t.index ["group_id"], name: "index_hunts_on_group_id"
    t.index ["indicator"], name: "index_hunts_on_indicator"
  end

  create_table "hunts_conditions", force: :cascade do |t|
    t.integer "test_id", null: false
    t.integer "operator", default: 0, null: false
    t.text "condition"
    t.integer "order", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["test_id"], name: "index_hunts_conditions_on_test_id"
  end

  create_table "hunts_feed_results", id: :string, force: :cascade do |t|
    t.integer "feed_id", null: false
    t.string "author_name"
    t.string "title"
    t.text "description"
    t.datetime "timestamp"
    t.json "indicators"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feed_id"], name: "index_hunts_feed_results_on_feed_id"
  end

  create_table "hunts_feeds", force: :cascade do |t|
    t.string "keyword", default: "*", null: false
    t.integer "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "source", default: 0, null: false
    t.datetime "last_refreshed"
    t.index ["group_id"], name: "index_hunts_feeds_on_group_id"
  end

  create_table "hunts_test_results", force: :cascade do |t|
    t.integer "result", default: 0, null: false
    t.integer "test_id", null: false
    t.integer "hunt_result_id", null: false
    t.jsonb "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ttp_id"
    t.index ["hunt_result_id"], name: "index_hunts_test_results_on_hunt_result_id"
    t.index ["test_id"], name: "index_hunts_test_results_on_test_id"
  end

  create_table "hunts_tests", force: :cascade do |t|
    t.string "type", null: false
    t.integer "revision", default: 0, null: false
    t.integer "hunt_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "lua_script_upload_id"
    t.string "lua_script_description"
    t.index ["hunt_id"], name: "index_hunts_tests_on_hunt_id"
    t.index ["lua_script_upload_id"], name: "index_hunts_tests_on_lua_script_upload_id"
    t.index ["revision"], name: "index_hunts_tests_on_revision"
  end

  create_table "line_items", id: :serial, force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.integer "charge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "item_type", null: false
    t.jsonb "meta"
    t.index ["charge_id"], name: "index_line_items_on_charge_id"
  end

  create_table "logic_rules", force: :cascade do |t|
    t.integer "app_id"
    t.integer "user_id"
    t.jsonb "rules", null: false
    t.integer "account_id"
    t.string "account_path"
    t.string "actions", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dependencies", default: [], array: true
    t.text "description"
    t.index ["app_id", "account_id"], name: "index_logic_rules_on_app_id_and_account_id"
    t.index ["app_id"], name: "index_logic_rules_on_app_id"
  end

  create_table "lookup_skus", id: :string, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_lookup_skus_on_name"
  end

  create_table "mapping_configs", force: :cascade do |t|
    t.integer "account_id"
    t.ltree "account_path"
    t.string "map_type"
    t.jsonb "details"
  end

  create_table "move_codes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "account_id"
    t.datetime "expiration"
  end

  create_table "pghero_query_stats", force: :cascade do |t|
    t.text "database"
    t.text "user"
    t.text "query"
    t.bigint "query_hash"
    t.float "total_time"
    t.bigint "calls"
    t.datetime "captured_at"
    t.index ["database", "captured_at"], name: "index_pghero_query_stats_on_database_and_captured_at"
  end

  create_table "pghero_space_stats", force: :cascade do |t|
    t.text "database"
    t.text "schema"
    t.text "relation"
    t.bigint "size"
    t.datetime "captured_at"
    t.index ["database", "captured_at"], name: "index_pghero_space_stats_on_database_and_captured_at"
  end

  create_table "phones", force: :cascade do |t|
    t.integer "account_id"
    t.text "numbers", default: [], array: true
    t.integer "category"
    t.index ["account_id", "category"], name: "index_phones_on_account_id_and_category"
  end

  create_table "plan_apps", force: :cascade do |t|
    t.bigint "plan_id"
    t.bigint "app_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plan_transitions", force: :cascade do |t|
    t.integer "from_plan"
    t.integer "to_plan"
  end

  create_table "plans", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "frequency", null: false
    t.integer "price_per_frequency_cents", default: 0, null: false
    t.string "price_per_frequency_currency", default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published", default: false
    t.integer "included_devices"
    t.integer "price_per_device_overage_cents", default: 0
    t.string "price_per_device_overage_currency", default: "USD"
    t.integer "providers_count", default: 0, null: false
    t.integer "on_demand_analysis_types", default: 0
    t.integer "on_demand_hunt_types", default: 0
    t.boolean "threat_hunting", default: true
    t.boolean "threat_intel_feeds", default: true
    t.boolean "managed"
    t.text "subscribed_hooks", default: [], array: true
    t.text "unsubscribed_hooks", default: [], array: true
    t.integer "accounts_count", default: 0
    t.integer "included_office_365_mailboxes"
    t.integer "price_per_office_365_mailbox_overage_cents", default: 0
    t.string "price_per_office_365_mailbox_overage_currency", default: "USD"
    t.integer "included_firewalls", default: 0
    t.integer "price_per_firewall_overage_cents", default: 0
    t.string "price_per_firewall_overage_currency", default: "USD"
    t.boolean "trial"
    t.integer "payment_plan"
    t.boolean "hide_billing", default: false
    t.boolean "hide_unassigned_apps", default: false
    t.string "plan_type"
    t.boolean "direct_pay", default: true
  end

  create_table "pre_maps", force: :cascade do |t|
    t.integer "account_id"
    t.ltree "account_path"
    t.string "target_id"
    t.integer "app_id"
    t.integer "mapping_config_id"
    t.string "map_type"
  end

  create_table "psa_configs", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "credential_id", null: false
    t.jsonb "configs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_psa_configs_on_account_id"
  end

  create_table "psa_configs_cached_companies", force: :cascade do |t|
    t.bigint "psa_config_id"
    t.string "name", null: false
    t.string "source", null: false
    t.string "external_id", null: false
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["psa_config_id", "source", "external_id"], name: "idx_cached_companies_on_source_external_id", unique: true
  end

  create_table "psa_configs_cached_company_types", force: :cascade do |t|
    t.bigint "psa_config_id"
    t.string "name", null: false
    t.string "source", null: false
    t.string "external_id", null: false
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["psa_config_id", "source", "external_id"], name: "idx_cached_company_types_on_source_external_id", unique: true
  end

  create_table "psa_configs_cached_company_types_companies", force: :cascade do |t|
    t.bigint "psa_config_id", null: false
    t.bigint "psa_configs_cached_company_id", null: false
    t.bigint "psa_configs_cached_company_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["psa_config_id", "psa_configs_cached_company_type_id", "psa_configs_cached_company_id"], name: "idx_cached_company_types_companies_unique_index_on_mapping", unique: true
    t.index ["psa_configs_cached_company_id"], name: "idx_psa_cached_company_types_companies_on_company"
    t.index ["psa_configs_cached_company_type_id"], name: "idx_psa_cached_company_types_companies_on_type"
  end

  create_table "psa_customer_maps", force: :cascade do |t|
    t.integer "account_id"
    t.string "psa_company_id"
    t.integer "psa_type"
    t.integer "psa_config_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "psa_configs_cached_company_id"
    t.index ["psa_configs_cached_company_id"], name: "index_psa_customer_maps_on_psa_configs_cached_company_id"
  end

  create_table "ref_secure_scores", id: :string, force: :cascade do |t|
    t.boolean "scored"
    t.boolean "deprecated"
    t.float "max_score"
    t.jsonb "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "remediation_plans", force: :cascade do |t|
    t.string "account_path"
    t.integer "incident_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["incident_id"], name: "index_remediation_plans_on_incident_id"
  end

  create_table "remediations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "result_id"
    t.integer "status"
    t.integer "remediation_plan_id"
    t.string "type"
    t.string "target_id"
    t.jsonb "actions"
    t.string "duplicate_check"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
    t.string "status_detail"
    t.index ["duplicate_check"], name: "index_remediations_on_duplicate_check"
    t.index ["remediation_plan_id"], name: "index_remediations_on_remediation_plan_id"
    t.index ["result_id"], name: "index_remediations_on_result_id"
  end

  create_table "report_accounts", force: :cascade do |t|
    t.integer "account_id"
    t.ltree "account_path"
    t.string "name"
    t.string "type"
    t.date "start_date"
    t.date "end_date"
    t.index ["account_path"], name: "index_report_accounts_on_account_path"
  end

  create_table "report_app_results", force: :cascade do |t|
    t.integer "app_id", null: false
    t.ltree "account_path", null: false
    t.date "date"
    t.integer "count", null: false
    t.integer "verdict"
    t.jsonb "details"
    t.index ["account_path"], name: "index_report_app_results_on_account_path"
    t.index ["date"], name: "index_report_app_results_on_date"
  end

  create_table "report_billable_instances", force: :cascade do |t|
    t.integer "billable_instance_id"
    t.integer "line_item_type"
    t.date "start_date"
    t.date "end_date"
    t.string "display_name"
  end

  create_table "report_devices", force: :cascade do |t|
    t.string "device_id", null: false
    t.ltree "account_path", null: false
    t.date "date"
    t.index ["account_path"], name: "index_report_devices_on_account_path"
  end

  create_table "report_incidents", force: :cascade do |t|
    t.ltree "account_path"
    t.integer "state"
    t.datetime "create_date"
    t.datetime "close_date"
    t.jsonb "details"
    t.integer "incident_id"
    t.index ["account_path"], name: "index_report_incidents_on_account_path"
  end

  create_table "report_usage_data", force: :cascade do |t|
    t.integer "device_count"
    t.integer "firewall_count"
    t.integer "mailbox_count"
    t.integer "account_id"
    t.ltree "account_path"
    t.date "date"
    t.integer "plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "result_archives", force: :cascade do |t|
    t.string "upload_id"
    t.integer "customer_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_result_archives_on_customer_id"
  end

  create_table "rocketcyber_integration_maps", force: :cascade do |t|
    t.integer "account_id"
    t.ltree "account_path"
    t.string "target_id"
    t.integer "app_id"
    t.integer "mapping_config_id"
    t.string "map_type"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.boolean "can_customize_logo", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "channel", default: 0
    t.boolean "uninstall", default: false, null: false
    t.string "url"
    t.string "license_key"
    t.integer "verbosity", default: 2, null: false
    t.boolean "offline", default: false, null: false
    t.boolean "super", default: false, null: false
    t.integer "polling", default: 60, null: false
    t.boolean "report_agent_errors", default: true, null: false
    t.integer "parallel_sub_task_count", default: 10, null: false
    t.integer "file_hash_refresh_interval", default: 604800
    t.integer "app_result_cache_age", default: 86400
    t.integer "max_cpu_usage", default: 2
    t.integer "full_disk_scan_time", default: 1
    t.jsonb "admin_config", default: {}
    t.bigint "max_memory_usage", default: 150000000
    t.integer "max_sustained_memory_usage", default: 600
    t.boolean "auto_remediate"
    t.jsonb "device_inactivity_thresholds"
    t.jsonb "two_factors"
    t.integer "user_session_timeout"
    t.integer "device_expiration"
    t.index ["account_id"], name: "index_settings_on_account_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "account_id"
    t.integer "event_types"
    t.jsonb "configuration"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_subscriptions_on_account_id"
  end

  create_table "system_hunts_categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "text_searches", force: :cascade do |t|
    t.string "searchable_type"
    t.string "searchable_id"
    t.text "blob"
    t.text "auto_complete_description"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_text_searches_on_account_id"
    t.index ["searchable_type", "searchable_id"], name: "index_text_searches_on_searchable_type_and_searchable_id"
  end

  create_table "ttps", id: :string, force: :cascade do |t|
    t.string "tactic", null: false
    t.string "technique", null: false
    t.text "description", null: false
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "remediation"
  end

  create_table "uploads", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "status", default: 0
    t.string "sourceable_type"
    t.string "sourceable_id"
    t.string "filename"
    t.integer "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "support_file", default: false, null: false
    t.boolean "protected", default: false, null: false
    t.text "tags", default: [], array: true
    t.index ["sourceable_type", "sourceable_id"], name: "index_uploads_on_sourceable_type_and_sourceable_id"
    t.index ["status"], name: "index_uploads_on_status"
    t.index ["support_file", "protected"], name: "index_uploads_on_support_file_and_protected"
  end

  create_table "user_roles", id: :serial, force: :cascade do |t|
    t.integer "role", default: 0, null: false
    t.integer "account_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_user_roles_on_account_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.integer "admin_role", default: 0, null: false
    t.string "timezone", default: "Central Time (US & Canada)", null: false
    t.datetime "accepted_tos_at"
    t.integer "second_factor_attempts_count", default: 0
    t.string "encrypted_otp_secret_key"
    t.string "encrypted_otp_secret_key_iv"
    t.string "encrypted_otp_secret_key_salt"
    t.string "direct_otp"
    t.datetime "direct_otp_sent_at"
    t.datetime "totp_timestamp"
    t.text "otp_backup_codes", array: true
    t.integer "session_timeout", default: 14400
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["encrypted_otp_secret_key"], name: "index_users_on_encrypted_otp_secret_key", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "plan_apps", "apps"
  add_foreign_key "plan_apps", "plans"
  add_foreign_key "psa_configs_cached_companies", "psa_configs"
  add_foreign_key "psa_configs_cached_company_types", "psa_configs"
  add_foreign_key "subscriptions", "accounts"
end
