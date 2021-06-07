if threat.threatable.is_a?(Apps::DeviceResult)
  egress_ip = egress_ips.find { |i_egress_ip| threat.threatable.device.egress_ip_id == i_egress_ip.id }

  if threat.threatable&.details&.direction == "outbound"
    # Swap directions
    json.egress_ip do
      json.latitude threat.latitude.to_f
      json.longitude threat.longitude.to_f
    end

    json.threat do
      json.latitude egress_ip.latitude.to_f
      json.longitude egress_ip.longitude.to_f
      json.country_flag_url asset_url("flags/#{threat.country}.png")
    end
  else
    json.threat do
      json.latitude threat.latitude.to_f
      json.longitude threat.longitude.to_f
      json.country_flag_url asset_url("flags/#{threat.country}.png")
    end

    json.egress_ip do
      json.latitude egress_ip.latitude.to_f
      json.longitude egress_ip.longitude.to_f
    end
  end

  json.detection_date((threat.threatable&.detection_date || threat.updated_at).to_f)

  json.summary ApplicationController.renderer.new(
    https:     Rails.application.config.force_ssl,
    http_host: ENV.fetch(I18n.t("application.host"), "example.com")
  ).render(partial: "shared/threats/threat_summary", locals: { threat: threat })
elsif threat.threatable.is_a?(Apps::Office365Result)
  egress_ip = [
    { latitude: 47.6062, longitude: -122.3321 },
    { latitude: 32.7767, longitude: -96.7970 },
    { latitude: 41.8781, longitude: -87.6298 },
    { latitude: 38.9072, longitude: -77.0369 }
  ].sample

  json.threat do
    json.latitude threat.latitude.to_f
    json.longitude threat.longitude.to_f
    json.country_flag_url asset_url("flags/#{threat.country}.png")
  end

  json.egress_ip do
    json.latitude egress_ip[:latitude].to_f
    json.longitude egress_ip[:longitude].to_f
  end

  json.detection_date((threat.threatable&.detection_date || threat.updated_at).to_f)

  json.summary ApplicationController.renderer.new(
    https:     Rails.application.config.force_ssl,
    http_host: ENV.fetch(I18n.t("application.host"), "example.com")
  ).render(partial: "shared/threats/threat_summary", locals: { threat: threat })
elsif threat.threatable.nil?
  egress_ip = egress_ips.sample

  json.threat do
    json.latitude threat.latitude.to_f
    json.longitude threat.longitude.to_f
    json.country_flag_url asset_url("flags/#{threat.country}.png")
  end

  json.egress_ip do
    json.latitude egress_ip[:latitude].to_f
    json.longitude egress_ip[:longitude].to_f
  end

  json.detection_date((threat.detection_date || threat.updated_at).to_f)

  json.summary ApplicationController.renderer.new(
    https:     Rails.application.config.force_ssl,
    http_host: ENV.fetch(I18n.t("application.host"), "example.com")
  ).render(partial: "shared/threats/threat_summary", locals: { threat: threat })
end
