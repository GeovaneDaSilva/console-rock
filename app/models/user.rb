# Represents a user who can authenticate
class User < ApplicationRecord
  self.ignored_columns = %w[hubspot_updated_at hubspot_contact_id]

  audited

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :timeoutable,
         :two_factor_authenticatable, :two_factor_backupable

  attr_accessor :new_provider_name
  attr_writer :from_sign_up
  attr_reader :accept_tos

  has_many :roles, class_name: "UserRole", dependent: :destroy
  has_many :uploads, as: :sourceable, dependent: :destroy
  has_many :accounts, through: :roles

  after_create :create_new_provider, if: :from_sign_up?

  enum admin_role: {
    # not an admin: 0,
    support:      10,
    soc_operator: 60,
    omnipotent:   100
  }

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :name, format: { with: /\A.+\s.+\z/ }
  validates :new_provider_name, presence: true, if: :from_sign_up?
  validates :timezone, inclusion: { in: TIMEZONENAMES }
  validates :session_timeout, numericality: { greater_than_or_equal_to: 1 }, allow_blank: true

  validates :password_confirmation, presence: true, if: proc { @password }

  has_one_time_password encrypted: true

  scope :owners, -> { includes(:roles).where(user_roles: { role: UserRole.roles[:owner] }) }

  def timeout_in
    admin? ? 1.week : (session_timeout || 30).minutes
  end

  def name
    [first_name, last_name].reject(&:blank?).join(" ")
  end

  def short_name
    "#{first_name} #{initials.last}."
  end

  def name=(name)
    self.first_name, self.last_name = name.split(" ", 2)
  end

  def email=(email_address)
    super email_address&.downcase
  end

  def accept_tos=(val)
    self.accepted_tos_at = DateTime.current if [true, "1"].include?(val)
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later(queue: "mailers")
  end

  def admin?
    !admin_role.nil?
  end

  # Used for Intercom/Hubspot only
  # Optimistic results here
  def subscription_status
    provider_scope = Provider.joins(:users).where(users: { id: id })

    return "Current" if provider_scope.current.any?
    return "Past Due" if provider_scope.past_due.any?
    return "Active Trial" if provider_scope.trial.any?
    return "Expired Trial" if provider_scope.trial_expired.any?

    "Unknown"
  end

  def account_ids
    Rails.cache.fetch(["v1/user/account_ids", self, accounts.pluck(:id)]) do
      accounts.collect { |account| account.self_and_all_descendants.pluck(:id) }.flatten
    end
  end

  # if we decide to start sending codes via SMS, add that here
  def send_two_factor_authentication_code(code); end

  def need_two_factor_authentication?(_request)
    !otp_secret_key.nil? && !otp_backup_codes.nil?
  end

  def remove_two_factor_authentication!
    update(otp_backup_codes: nil, encrypted_otp_secret_key: nil,
      encrypted_otp_secret_key_iv: nil, encrypted_otp_secret_key_salt: nil)
  end

  def authenticate_otp(code, options = {})
    return true if direct_otp && authenticate_direct_otp(code)
    return true if totp_enabled? && authenticate_totp(code, options)
    return true if authenticate_backup_code(code)

    false
  end

  def generate_qr!
    self.otp_secret_key ||= generate_totp_secret

    if save
      uri =  "otpauth://totp/#{I18n.t('application.name')}?secret=#{otp_secret_key}"
      return RQRCode::QRCode.new(uri)
    end
    false
  end

  def render_backup_codes
    codes = []
    return codes unless otp_backup_codes.empty?

    codes = generate_otp_backup_codes
    return codes if save

    flash.now[:error] = "Problem generating backup codes"
  end

  private

  def create_new_provider
    Providers::Create.new(self).call
  end

  def from_sign_up?
    @from_sign_up.present?
  end

  def initials
    [
      first_name.first,
      last_name.first
    ]
  end

  def authenticate_backup_code(code)
    invalidate_otp_backup_code!(code)
  end
end
