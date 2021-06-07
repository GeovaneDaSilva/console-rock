module ReportingData
  # Populate a usage table for Sales' daily reports
  class PopulateUsageData
    # This assumes there is no sub-account billing
    # As of 3/29 that is a valid assumption EXCEPT FOR
    def call
      DatabaseTimeout.timeout(0) do
        providers = Provider.where("paid_thru > ?", DateTime.current).where.not(plan_id: nil)
        providers.where(status: :active).find_each do |provider|
          # skip Pax8 - Distributor and Kaseya - Production
          # TODO: swap this band-aid out for a real fix.
          next if [5899, 9578].include?(provider.id)

          device_count = provider.all_descendant_devices.where("last_connected_at > ?", 1.month.ago).count
          billable_instances = provider.all_descendant_billable_instances.where(active: true)
                                       .where("updated_at > ?", 1.month.ago).group(:line_item_type).count

          today_usage(provider).update(
            device_count:   device_count,
            firewall_count: billable_instances["firewall"],
            mailbox_count:  billable_instances["office_365_mailbox"]
          )
        end
      end
    end

    private

    def today_usage(provider)
      ReportUsageData.where(
        date:         Time.zone.today,
        account_id:   provider.id,
        account_path: provider.path,
        plan_id:      provider.plan_id
      ).first_or_initialize
    end
  end
end
