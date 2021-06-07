TIMEZONENAMES = (ActiveSupport::TimeZone::MAPPING.keys +
    TZInfo::Timezone.all_data_zones.collect(&:name)).freeze
