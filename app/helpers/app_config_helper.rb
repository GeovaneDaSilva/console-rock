# :nodoc
module AppConfigHelper
  def additional_config_countries
    default_countries = APP_CONFIGS[:cyberterrorist_network_connection][:enabled_countries].keys

    COUNTRIES.reject { |k| default_countries.include?(k) }
  end

  def additional_config_countries2(one, two)
    default_countries = APP_CONFIGS[one][two].keys

    COUNTRIES.reject { |k| default_countries.include?(k) }
  end

  def additional_events(whose)
    default_events = APP_CONFIGS[:syslog][whose].keys

    FIREWALLS[whose].reject { |k| default_events.include?(k) }
  end
end
