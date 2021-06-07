module Apps
  # An group of app results representing an incident
  class Incident < ApplicationRecord
    audited

    attr_accessor :result_account_paths

    has_many :results, dependent: :nullify do
      def apps
        App.where(id: pluck(:app_id).uniq)
      end
    end
    has_one :remediation_plan, dependent: :destroy, inverse_of: :incident

    belongs_to :creator, class_name: "User"
    belongs_to :resolver, class_name: "User", optional: true

    enum state: {
      draft:     0,
      published: 25,
      resolved:  100
    }

    scope :published, -> { where("state > ?", 0) }
    scope :not_open, -> { where.not("state > ?", 25) }
    scope :open, -> { where("state <= ?", 25) }
    scope :published_or_resolved, -> { where("state >= ?", 25) }
    scope :not_resolved, -> { where.not("state = ?", 100) }

    validates :title, :remediation, :description, presence: true
    validate :homogeneous_result_account_paths

    def resolver=(val)
      self.resolved_at = DateTime.current
      super
    end

    def published!
      self.published_at = DateTime.current
      super
    end

    def open?
      self.class.states[state] <= 25
    end

    def reopen
      return if open?

      self.state = :draft
    end

    def account
      @account ||= Account.where(path: account_path).first
    end

    private

    # Incidents can't span different customers
    def homogeneous_result_account_paths
      return if results.collect(&:account_path).uniq.size <= 1

      errors.add(:result_account_paths, "cannot span different accounts")
    end
  end
end
