# Customer accounts
class Customer < Account
  alias_attribute :registration_key, :license_key # RM after deployed to production

  enum onboarding: {
    deploy_agent: 0,
    completed:    1000
  }

  has_many :devices
  has_many :egress_ips, dependent: :destroy
  has_many :apps_results, class_name: "Apps::Result", dependent: :destroy

  has_one :ms_graph_credential, class_name: "Credentials::MsGraph", dependent: :destroy
  has_one :cylance_credential, class_name: "Credentials::Cylance", dependent: :destroy

  belongs_to :agent_release, optional: true

  after_initialize :set_license_key
  after_destroy :destroy_devices

  after_commit :queue_agent_releaser, on: [:create]
  after_commit :store_deleted_customer, on: [:destroy]

  validates :license_key, uniqueness: true, presence: true

  def provider
    Account.where("path = SUBPATH(?, 0, NLEVEL(?) - 1)", path, path).first
  end

  def ancestors
    self_and_ancestors.where.not(id: id)
  end

  def self_and_ancestors
    Account.where(id: super.unscope(where: :type))
  end

  def cylance_credential?
    respond_to?(:cylance_credential) && !cylance_credential.nil?
  end

  def text_search_blob
    [name, contact_name, license_key].reject(&:blank?).join(" ")
  end

  def signed_license_key
    verifier = ActiveSupport::MessageVerifier.new(
      ENV["SOCKET_PROXY_SECRET"], digest: "SHA256", serializer: JSON
    )

    payload = { license_key: license_key }
    verifier.generate(payload, expires_in: 2.weeks)
  end

  def license_key
    db_license_key = super

    if db_license_key && id
      db_license_key + "-#{id}"
    else
      db_license_key
    end
  end

  def logo; nil; end

  def parent_logo; nil; end

  def ancestor_tree
    self_and_all_ancestors.unscope(where: :type).order(path: :asc).collect(&:name).join(" > ")
  end

  private

  def build_settings
    return if persisted?

    self.setting = Setting.new

    attrs = provider ? provider.setting.setting_fields : {}
    setting.assign_attributes(attrs)
  end

  def destroy_devices
    Device.where(id: device_ids).destroy_all
  end

  def set_license_key
    return if persisted? && license_key.present?

    count = 0

    while license_key.blank? || self.class.where(license_key: license_key).exists?
      count += 1
      raise("Unable to generate unique registration key in a resonable number of attempts") if count > 10

      self.license_key = generate_key
    end
  end

  def generate_key
    SecureRandom.hex(10).gsub(/0|o|l|i|1|b|1/, "")[0..8]
  end

  def queue_agent_releaser
    ServiceRunnerJob.perform_later("AgentReleases::Releaser")
  end

  def store_deleted_customer
    DeletedCustomer.create(
      license_key: self[:license_key],
      details:     {
        name: name, path: path, ancestor_tree: ancestor_tree
      }
    )
  end
end
