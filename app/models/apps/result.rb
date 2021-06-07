module Apps
  # :nodoc
  class Result < ApplicationRecord
    include Verdictable
    has_one :geocoded_threat, as: :threatable, dependent: :destroy
    has_many :remediations, class_name: "Remediation", foreign_key: :result_id,
      dependent: :destroy, inverse_of: :result

    belongs_to :app
    belongs_to :customer
    belongs_to :incident_response, optional: true
    belongs_to :incident, optional: true, touch: true

    enum action_state: {
      requested: 100,
      resolved:  300,
      errored:   400
    }

    enum archive_state: {
      active:     0,
      archived:   200,
      summarized: 400
    }

    scope :marked_as_incident, -> { where.not(incident: true) }
    scope :with_incident_responses, -> { where.not(incident_response_id: nil) }
    scope :within_date_month, ->(date) { where(detection_date: date.beginning_of_month..date.end_of_month) }
    scope :pre_action, -> { where(action_state: nil) }
    scope :with_action, -> { where.not(action_state: nil) }
    scope :details_ilike, ->(query) { where("details::text ILIKE ?", "%#{sanitize_sql_like(query)}%") }
    scope :with_incident, -> { where.not(incident_id: nil) }
    scope :without_incident, -> { where(incident_id: nil) }
    scope :with_enabled_apps, -> { joins(:app).merge(App.enabled.ga) }

    validates :account_path, presence: true

    after_create_commit :increment_counter_cache
    after_destroy_commit :decrement_counter_cache
    after_update_commit :update_counter_cache

    def details
      @details ||= ::TestResults::BaseJson.new(super)
    rescue StandardError
      # Rails.logger.fatal("Unable to properly render Apps::Result #{id}, #{e.message}, #{e.backtrace.first}")
      ::TestResults::BaseJson.new(
        type:       "Error",
        attributes: { "Error": "Unable to properly render details. Error Code: #{id}" }
      )
    end

    def pre_action?
      action_state.nil?
    end

    def with_action?
      action_state.present?
    end

    def whitelistable_options
      whitelist_results = {}.with_indifferent_access

      app_whitelist_config.each do |whitelist_type, map_config|
        whitelistable_values(map_config).each do |value|
          if whitelist_results[whitelist_type]
            whitelist_results[whitelist_type] << value
          else
            whitelist_results[whitelist_type] = Set[value]
          end
        end
      end

      whitelist_results
    end

    def app_whitelist_config
      APP_WHITELISTS.dig(app.configuration_type)
    end

    # Walks the given paths, collecting single value or arrays of values
    # Returns an array
    # paths => ["details", "foo", "bar"]
    def values_at_path(paths)
      paths.reduce(self) do |memo, path|
        if memo.is_a?(Array)
          memo.collect { |sub_memo| sub_memo.try(path) }.flatten
        else
          [memo.try(path)]
        end
      end.compact
    end

    # Use advisory locks, as many threads may be attempting to create
    # app results for a given app/account_path/verdict and/or device_id
    def counter_cache
      @counter_cache ||= if is_a?("Apps::CloudResult".constantize)
                           CounterCache.with_advisory_lock(counter_cache_creation_lock_key) do
                             CounterCache.find_or_create_by(
                               app: app, account_path: account_path, verdict: verdict, device_id: nil
                             )
                           end
                         elsif is_a?("Apps::DeviceResult".constantize)
                           CounterCache.with_advisory_lock(counter_cache_creation_lock_key) do
                             CounterCache.find_or_create_by(
                               app: app, account_path: account_path, verdict: verdict, device_id: device_id
                             )
                           end
                         end
    end

    private

    def counter_cache_creation_lock_key
      "apps/counter_cache/#{app_id}/#{account_path}"
    end

    def counter_cache_update_lock_key
      "apps/counter_cache/#{counter_cache.id}"
    end

    def whitelistable_values(map_config)
      map_config[:result_paths].collect do |result_path|
        values_at_path(result_path)
      end.flatten.compact
    end

    def increment_counter_cache
      CounterCache.with_advisory_lock(counter_cache_update_lock_key) do
        return if reload.counter_cache_id.present?

        CounterCache.update_counters counter_cache.id, count: 1
        update_column :counter_cache_id, counter_cache.id

        device.update_counters([verdict]) if respond_to?(:device)
      end
    end

    def decrement_counter_cache
      CounterCache.with_advisory_lock(counter_cache_update_lock_key) do
        return if counter_cache_id.blank?
        return if counter_cache.reload.count.zero?

        CounterCache.update_counters counter_cache.id, count: -1

        device.update_counters([verdict]) if respond_to?(:device)
      end
    end

    # Handle verdict mutation at whatever cost
    def update_counter_cache
      return unless previous_changes["verdict"]

      CounterCache.with_advisory_lock(counter_cache_update_lock_key) do
        CounterCache.update_counters counter_cache_id, count: -1 if counter_cache_id.present?

        @counter_cache = nil
        CounterCache.update_counters counter_cache.id, count: 1
        update_column :counter_cache_id, counter_cache.id

        device.update_counters(previous_changes["verdict"]) if respond_to?(:device)
      end
    end
  end
end
