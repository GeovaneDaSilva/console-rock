# A Managed Service Provider
class Provider < Account
  attr_accessor :skip_nesting

  enum onboarding: {
    add_customer: 0,
    completed:    1000
  }

  belongs_to :logo, -> { where(status: :completed) }, class_name: "Upload"

  validates :name, presence: true

  after_destroy  :destroy_customers
  after_destroy  :destroy_uploads
  after_update :set_agent_release_group

  def customers
    Customer.where("path <@ ? AND nlevel(path) = NLEVEL(?) + 1", path, path)
  end

  def all_descendant_customers
    Customer.where("path <@ ?", path)
  end

  def parent_logo
    ancestors.joins(:setting)
             .where.not(logo: nil)
             .where(settings: { can_customize_logo: true })
             .order(:path)
             .last&.logo
  end

  def distributor?
    @distributor ||= all_descendants.providers.any?
  end

  private

  def destroy_customers
    Customer.where("path <@ ?", ltree_path_in_database).destroy_all
  end

  def destroy_uploads
    logo&.trashed!

    uploads.find_each(&:trashed!)
  end

  def build_settings
    return if persisted?

    self.setting = Setting.new(can_customize_logo: true)

    attrs = path.present? && !root? ? parent.setting.setting_fields : {}
    setting.assign_attributes(attrs)
  end

  def set_agent_release_group
    return unless path.to_s.include?(id.to_s) # Guard against path changes
    return unless previous_changes["agent_release_group"]

    all_descendants.update_all(agent_release_group: agent_release_group)
  end
end
