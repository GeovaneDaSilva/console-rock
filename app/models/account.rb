# Base STI table
class Account < ApplicationRecord
  self.ignored_columns = %w[hubspot_updated_at hubspot_company_id disable_chat_support]

  audited

  TRIAL_DAYS = 21
  ACTIONABLE_PAST_DUE_DAYS = 7
  BARRACUDA_TRIAL_DAYS = 14

  include Nearestable
  include AttrJsonable
  include Encryptable
  include Searchable
  include LtreeManyable
  include PgSearch::Model

  pg_search_scope :search_name, against: :name, using: {
    tsearch: { prefix: true, negation: true, dictionary: "english" }
  }

  pg_search_scope :search_any_name, against: :name, using: {
    tsearch: { prefix: true, negation: true, dictionary: "english", any_word: true }
  }

  ltree :path

  attr_reader :settings_inheritance, :unset_plan
  attr_accessor :changed_setting_attributes

  enum status: {
    active:        0,
    trial_expired: 2,
    suspended:     5,
    canceled:      10
  }

  enum onboarding: {
    completed: 1000
  }

  attr_json_accessor :api_keys, :alien_vault_api_key, :alien_vault_api_key_iv,
                     :virus_total_api_key, :virus_total_api_key_iv

  encrypt :alien_vault_api_key, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  encrypt :virus_total_api_key, key: Base64.decode64(
    ENV.fetch("API_KEY_ENCRYPTION_KEY", Base64.encode64(SecureRandom.random_bytes(32)).delete("\n"))
  )

  has_one :setting, dependent: :destroy

  ltree_many :devices, class_name: "Device", foreign_key: :account_path, dependent: :destroy
  ltree_many :app_results, class_name: "Apps::Result", foreign_key: :account_path, dependent: :destroy
  ltree_many :device_app_results, class_name: "Apps::DeviceResult", foreign_key: :account_path
  ltree_many :cloud_app_results, class_name: "Apps::CloudResult", foreign_key: :account_path
  ltree_many :office365_results, class_name: "Apps::Office365Result", foreign_key: :account_path
  ltree_many :sentinelone_results, class_name: "Apps::SentineloneResult", foreign_key: :account_path
  ltree_many :webroot_results, class_name: "Apps::WebrootResult", foreign_key: :account_path
  ltree_many :incidents, class_name: "Apps::Incident", foreign_key: :account_path, dependent: :destroy
  ltree_many :cylance_results, class_name: "Apps::CylanceResult", foreign_key: :account_path
  ltree_many :passly_results, class_name: "Apps::PasslyResult", foreign_key: :account_path
  ltree_many :ironscales_results, class_name: "Apps::IronscalesResult", foreign_key: :account_path
  ltree_many :cysurance_results, class_name: "Apps::CysuranceResult", foreign_key: :account_path
  ltree_many :bitdefender_results, class_name: "Apps::BitdefenderResult", foreign_key: :account_path
  ltree_many :deep_instinct_results, class_name: "Apps::DeepInstinctResult", foreign_key: :account_path
  ltree_many :dns_filter_results, class_name: "Apps::DnsFilterResult", foreign_key: :account_path
  ltree_many :hibp_results, class_name: "Apps::HibpResult", foreign_key: :account_path
  ltree_many :hunt_results, class_name: "HuntResult", foreign_key: :account_path, dependent: :destroy
  ltree_many :billable_instances, foreign_key: :account_path, dependent: :destroy
  ltree_many :firewall_counters, foreign_key: :account_path, dependent: :destroy
  ltree_many :app_counter_caches, class_name: "Apps::CounterCache", foreign_key: :account_path,
                                  dependent: :delete_all

  has_many :uploads, as: :sourceable
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  has_one :sentinelone_credential, class_name: "Credentials::Sentinelone", dependent: :destroy
  has_one :psa_config, dependent: :destroy
  has_one :psa_customer_map, dependent: :destroy
  has_one :cached_company, through: :psa_customer_map
  has_one :webroot_credential, class_name: "Credentials::Webroot", dependent: :destroy
  has_one :cylance_credential, class_name: "Credentials::Cylance", dependent: :destroy
  has_one :passly_credential, class_name: "Credentials::Passly", dependent: :destroy
  has_one :bitdefender_credential, class_name: "Credentials::Bitdefender", dependent: :destroy
  has_one :deep_instinct_credential, class_name: "Credentials::DeepInstinct", dependent: :destroy
  has_one :hibp_credential, class_name: "Credentials::Hibp", dependent: :destroy
  has_one :ironscales_credential, class_name: "Credentials::Ironscales", dependent: :destroy
  has_one :connectwise_credential, class_name: "Credentials::Connectwise", dependent: :destroy
  has_one :datto_credential, class_name: "Credentials::Datto", dependent: :destroy
  has_one :sophos_credential, class_name: "Credentials::Sophos", dependent: :destroy
  has_one :dns_filter_credential, class_name: "Credentials::DnsFilter", dependent: :destroy
  has_one :duo_credential, class_name: "Credentials::Duo", dependent: :destroy
  has_one :cisco_umbrella_credential, class_name: "Credentials::CiscoUmbrella", dependent: :destroy

  has_many :owner_roles, -> { where(role: :owner) }, class_name: "UserRole", dependent: :destroy
  has_many :viewer_roles, -> { where(role: :viewer) }, class_name: "UserRole", dependent: :destroy
  has_many :owners, source: :user, through: :owner_roles
  has_many :viewers, source: :user, through: :viewer_roles
  has_many :groups, dependent: :destroy
  has_many :geocoded_threats, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :account_apps, dependent: :destroy
  has_many :apps, through: :account_apps
  has_many :app_configs, class_name: "Apps::AccountConfig", dependent: :destroy
  has_many :email_addresses, class_name: "Email", dependent: :destroy
  has_many :phones, dependent: :destroy
  has_many :move_codes, dependent: :destroy

  belongs_to :agent_release, optional: true
  belongs_to :plan, optional: true, counter_cache: true
  has_many :charges # No dependent option, keep these records indefinitely

  # Beware AR Callbacks that depend on path! See commit for details.
  after_initialize :build_settings
  after_commit :update_path_to_include_id, on: %i[create update]
  after_commit :update_descendant_settings, on: [:update]
  after_commit :set_trial_attributes, on: [:create]
  after_commit :break_cache, on: %i[update]
  after_commit :reset_account_id_caches
  after_create :create_default_group
  before_destroy :update_report_table

  scope :customers, -> { where(type: "Customer") }
  scope :providers, -> { where(type: "Provider") }
  scope :order_by_ids, ->(ids) { order(Arel.sql(ids.collect { |id| "id=#{id} DESC" }.join(", "))) }
  scope :marked_for_deletion, -> { where(marked_for_deletion: true) }
  scope :not_marked_for_deletion, -> { where(marked_for_deletion: false) }
  scope :not_trial, -> { joins(:plan).where(plans: { trial: [nil, false] }) }
  scope :with_plan, -> { where.not(plan: nil) }
  scope :all_trials, -> { joins(:plan).where(plans: { trial: true }) }
  scope :trial, -> { all_trials.where("paid_thru >= ?", Date.current) }
  scope :current, -> { not_trial.where("paid_thru >= ?", Date.current) }
  scope :past_due, -> { not_trial.where("paid_thru < ?", Date.current) }
  scope :trial_expired, -> { all_trials.where("paid_thru < ?", Date.current) }

  scope :actionable_past_due, lambda {
    where("paid_thru < ?", Date.current - ACTIONABLE_PAST_DUE_DAYS.days)
  }

  scope :chargeable, lambda {
    where.not(plan_id: nil, status: %i[suspended canceled])
         .where("paid_thru <= ?", DateTime.current.utc + 4.hours)
  }

  accepts_nested_attributes_for :setting

  validates :name, presence: true

  # Used for ordering of release, desc
  enum agent_release_group: {
    general:       0,
    bleeding_edge: 900,
    test_group_1:  950,
    test_group_2:  951,
    test_group_3:  952,
    test_group_4:  953,
    test_group_5:  954,
    internal:      1000
  }

  def self_and_all_descendant_ids
    Accounts::SelfAndSubAccountsIdCacher.fetch(self)
  end

  def unset_plan=(val)
    self.plan_id = nil if ActiveRecord::Type::Boolean.new.deserialize(val)
  end

  def subscribed?
    plan_id.present?
  end

  def trial?
    billing_account&.plan&.trial && paid_thru >= Date.current
  end

  def current?
    plan_id.present? && !plan.trial && paid_thru >= Date.current && !canceled?
  end

  def past_due?
    plan_id.present? && !plan.trial && paid_thru < Date.current && !canceled?
  end

  def actionable_past_due?
    paid_thru + ACTIONABLE_PAST_DUE_DAYS.days < Date.current
  end

  def days_past_due
    (Date.current - paid_thru).to_i
  end

  def trial_expired?
    (plan_id.nil? || plan&.trial) && paid_thru < Date.current
  end

  def chargeable?
    plan_id.present? && !plan&.trial && paid_thru <= Date.current && (!canceled? && !suspended?)
  end

  def plan_state
    %w[trial current past_due trial_expired].find do |plan_state|
      return plan_state.to_sym if send("#{plan_state}?")
    end
  end

  def last_charge_end_date
    charges.completed.last&.end_date || created_at
  end

  def paid_thru?(date)
    paid_thru >= date.to_datetime.end_of_day
  end

  def valid_credit_card?
    plan&.minimum_charge&.zero? || card_masked_number.present? && !charges.last&.failed?
  end

  def needs_credit_card?
    billing_account? && cc_pay? && subscribed? && card_masked_number.blank? && plan.minimum_charge.positive?
  end

  def paid_thru=(date)
    super

    self.status = :active if paid_thru >= DateTime.current.to_date
  end

  # TODO: fix this once we get a real alternate payment system up
  # (that doesn't depend on putting everyone on a different plan)
  def cc_pay?
    plan&.direct_pay && id != 3744
  end

  # "Simplified" human text of subscirption status
  def sales_status
    if trial?
      "Active Trial"
    elsif trial_expired?
      "Expired Trial"
    elsif canceled?
      "Canceled subscription"
    elsif past_due?
      "Suspended subscription - payment past due"
    else
      "Active subscription"
    end
  end

  def settings_inheritance=(value)
    @settings_inheritance = value.nil? ? :none : value.to_sym
  end

  def setting_attributes=(attrs)
    self.changed_setting_attributes = attrs
    super
  end

  def provider?
    type == "Provider"
  end

  def customer?
    type == "Customer"
  end

  def managed?
    billing_account&.plan&.managed?
  end

  # rubocop:disable Naming/MemoizedInstanceVariableName
  def root?
    # cache this value to reduce the number of db calls
    @is_root ||= super
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName

  def root
    return self if root?
    return nil if path.nil?

    @root ||= Rails.cache.fetch(root_cache_key, expires_in: 10.minutes) do
      ::Account.where("path = SUBPATH(?, 0, 1)", path).order(:id).first
    end
  end

  def parent
    Account.find_by(
      "#{ltree_scope.table_name}.#{ltree_path_column} = SUBPATH(?, 0, NLEVEL(?) - 1)",
      ltree_path, ltree_path
    )
  end

  def all_descendants
    Account.where("accounts.path <@ ?", path)
           .where.not(path: path)
  end

  # Includes self if a customer
  def all_descendant_customers
    Customer.where("accounts.path <@ ?", path)
            .where.not(path: path)
  end

  # Includes self
  def self_and_all_descendant_customers
    Customer.where("accounts.path <@ ?", path)
  end

  def root_and_root_descendants
    Account.where("accounts.path <@ SUBPATH(?, 0, 1)", path)
  end

  def self_and_all_descendants
    Account.where("accounts.path <@ ?", path)
  end

  def self_and_all_ancestors
    self_and_ancestors.unscope(where: :type)
  end

  def billing_account
    @billing_account ||= if root? || plan_id.present?
                           self
                         else
                           self_and_all_ancestors.where.not(plan_id: nil).order(path: :desc).first || root
                         end
  end

  def billing_account?
    billing_account == self
  end

  def account
    self
  end

  def provider
    provider? ? self : parent
  end

  def text_search_blob
    name
  end

  def auto_complete_description
    name
  end

  def subscription_cache_keys
    ["subscription/v1", billing_account.actionable_past_due?, billing_account.plan]
  end

  # Expensive DB call; possiblity of high memory consumption. Do not call in foreground.
  def self_and_ancestor_user_ids
    Account.where(id: self_and_ancestors.unscope(where: :type)).includes(:user_roles).collect do |account|
      account.user_roles.collect(&:user_id)
    end.flatten
  end

  def customer_scope
    customer? ? self : all_descendant_customers
  end

  def ms_credential?
    respond_to?(:ms_graph_credential) && !ms_graph_credential.nil?
  end

  def sentinelone_credential?
    respond_to?(:sentinelone_credential) && !sentinelone_credential.nil?
  end

  def sophos_credential?
    respond_to?(:sophos_credential) && !sophos_credential.nil?
  end

  def webroot_credential?
    respond_to?(:webroot_credential) && !webroot_credential.nil?
  end

  def cylance_credential?
    respond_to?(:cylance_credential) && !cylance_credential.nil?
  end

  def passly_credential?
    respond_to?(:passly_credential) && !passly_credential.nil?
  end

  def bitdefender_credential?
    respond_to?(:bitdefender_credential) && !bitdefender_credential.nil?
  end

  def ironscales_credential?
    respond_to?(:ironscales_credential) && !ironscales_credential.nil?
  end

  def deep_instinct_credential?
    respond_to?(:deep_instinct_credential) && !deep_instinct_credential.nil?
  end

  def dns_filter_credential?
    respond_to?(:dns_filter_credential) && !dns_filter_credential.nil?
  end

  def hibp_credential?
    respond_to?(:hibp_credential) && !hibp_credential.nil?
  end

  def duo_credential?
    respond_to?(:duo_credential) && !duo_credential.nil?
  end

  def cisco_umbrella_credential?
    respond_to?(:cisco_umbrella_credential) && !cisco_umbrella_credential.nil?
  end

  def app_config_for_app(app)
    Apps::AccountConfig.joins(:account).where(app: app, account_id: self_and_ancestors.select(:id))
                       .order("accounts.path DESC").first
  end

  def distributor?
    false
  end

  def psa_config
    PsaConfig.joins(:account).order(path: :desc).find_by(account: self_and_all_ancestors)
  end

  private

  def root_cache_key
    root_account_id = if root?
                        id
                      else
                        path.split(".").first
                      end
    "v1/Account:#{root_account_id}"
  end

  def break_cache
    Rails.cache.delete(root_cache_key)
  end

  def reset_account_id_caches
    Accounts::SelfAndSubAccountsIdCacher.clear_self_and_ancestor_caches!(self)
  end

  def update_path_to_include_id
    return if path =~ /(^|\.)#{id}(\.|$)/

    new_path = [path.to_s, id].reject(&:blank?).join(".")
    update_column(:path, new_path)
  end

  def build_settings; end

  # Force the settings down on the descendant providers.
  # Expensive update calls here to merge descendant provider's
  # customized settings.
  def update_descendant_settings
    return if changed_setting_attributes.nil? && settings_inheritance == :none

    case settings_inheritance
    when :merge
      merge_descendant_settings
    when :override
      override_descendant_settings
    end
  end

  def merge_descendant_settings
    Setting.where(account: all_descendants).update_all(changed_setting_attributes.to_h)
  end

  def override_descendant_settings
    attrs = setting.setting_fields.reject { |_k, v| v.blank? && !v.is_a?(FalseClass) }
    Setting.where(account: all_descendants).update_all(attrs)
  end

  def create_default_group
    groups.create(name: "All Devices", required: true)
  end

  def set_trial_attributes
    return unless paid_thru.nil?

    update_path_to_include_id unless path =~ /(^|\.)#{id}(\.|$)/

    trial_days = I18n.locale == :barracudamsp ? BARRACUDA_TRIAL_DAYS : TRIAL_DAYS
    new_paid_thru = billing_account&.paid_thru || DateTime.current.utc.beginning_of_day + trial_days.days
    update_column(:paid_thru, new_paid_thru)

    return unless billing_account? && plan_id.nil?

    new_plan_id = Plan.where(trial: true).first&.id
    update_column(:plan_id, new_plan_id)
  end

  def update_report_table
    ServiceRunnerJob.perform_later("UpdateReports::Account", id)
  end
end
