module R
  # fetches data required for the executive summary report
  class ExecutiveSummaryQuery
    prepend QueryCachable

    ExecutiveSummaryQueryError = Class.new(StandardError)
    AccountNotPresent = Class.new(ExecutiveSummaryQueryError)

    def initialize(account, start_time, end_time)
      @account = account
      # rubocop:disable Rails/Date
      @start_time = start_time.to_time
      @end_time = end_time.to_time
      # rubocop:enable Rails/Date

      raise AccountNotPresent if @account.blank?
    end

    attr_reader :account, :start_time, :end_time

    QueryCachable.cache :totals, :attack_countries, :incident_ids, :vulnerable_mailboxes,
                        :threat_detections_by_app, :incidents_resolved_total,
                        :incidents_open_total, :detections_total, :detections_ignored,
                        :detections_pending, :detections_remediated,
                        :billable_instances_by_line_item_counts, :active_devices_count

    def incident_ids
      incidents_scope.pluck(:id)
    end

    def billable_instances_by_line_item_counts
      account
        .all_descendant_billable_instances
        .active
        .group(:line_item_type)
        .where(updated_at: start_time..end_time)
        .count
    end

    def active_devices_count
      Devices::ConnectivityLog
        .where(connected_at: start_time..end_time)
        .where(device_id: account.all_descendant_devices.not_deleted)
        .select(:device_id)
        .distinct
        .count
    end

    def totals
      {
        device_count:               active_devices_count || 0,
        firewall_count:             billable_instances_by_line_item_counts["firewall"] || 0,
        office_365_mailboxes_count: billable_instances_by_line_item_counts["office_365_mailbox"] || 0
      }
    end

    def attack_countries
      account
        .all_descendant_app_results
        .with_enabled_apps
        .group("details -> 'attributes' ->> 'country'")
        .where("details -> 'attributes' ->> 'country' IS NOT NULL")
        .where(incident: incident_ids)
        .order(Arel.sql("count(*) DESC"))
        .limit(8)
        .count
    end

    def vulnerable_mailboxes
      Apps::Office365Result
        .where(incident: incident_ids)
        .with_enabled_apps
        .group("details->'attributes'->'user'->>'principalName'")
        .where("details->'attributes'->'user'->>'principalName' IS NOT NULL")
        .order(Arel.sql("count(*) DESC"))
        .limit(10)
        .count
    end

    def threat_detections_by_app
      account
        .all_descendant_app_results
        .with_enabled_apps
        .where(incident: incident_ids)
        .group("apps.title")
        .count
    end

    # Incidents
    # -----------------------------------------------
    def incidents_resolved_total
      account
        .all_descendant_incidents
        .where(created_at: start_time..end_time)
        .where(state: :resolved)
        .count
    end

    def incidents_open_total
      account
        .all_descendant_incidents
        .where(created_at: start_time..end_time)
        .where(state: :published)
        .count
    end

    # Detections
    # -----------------------------------------------
    def detections_total
      account
        .all_descendant_app_results
        .with_enabled_apps
        .where(detection_date: start_time..end_time)
        .count
    end

    def detections_threat_total
      detections_pending + detections_remediated
    end

    def detections_ignored
      account
        .all_descendant_app_results
        .with_enabled_apps
        .where(detection_date: start_time..end_time)
        .where(incident: nil)
        .count
    end

    def detections_pending
      account
        .all_descendant_app_results
        .with_enabled_apps
        .joins(:incident)
        .where(incident: incident_ids)
        .merge(Apps::Incident.where(state: :published))
        .count
    end

    def detections_remediated
      account
        .all_descendant_app_results
        .with_enabled_apps
        .joins(:incident)
        .where(incident: incident_ids)
        .merge(Apps::Incident.where(state: :resolved))
        .count
    end

    def detections_by_status
      [
        ["No remediation required", detections_ignored],
        ["Pending Resolution",      detections_pending],
        ["Resolved",                detections_remediated]
      ]
    end

    def detections_by_status?
      return false unless incidents_scope.any?

      [detections_ignored, detections_pending, detections_remediated].any?(&:positive?)
    end

    private

    # NOTE: supports QueryCachable
    def key_prefix
      ["v1", @account, @start_time, @end_time]
    end

    # NOTE: supports QueryCachable
    def expiry
      6.hours
    end

    def incidents_scope
      account
        .all_descendant_incidents
        .published.where(created_at: start_time..end_time)
    end

    def job_params
      [account, start_time.to_s, end_time.to_s]
    end
  end
end
