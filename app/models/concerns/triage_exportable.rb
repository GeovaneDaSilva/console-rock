# :nodoc
module TriageExportable
  def export_type
    @export_type ||= params[:export].downcase
  end

  def filename
    [account.name.parameterize, app&.title&.parameterize, "results"].compact.join("-")
  end

  def download_options
    opts = query_params.merge(app_result_id: params[:app_result_id])
    report_attributes.merge({ filename: filename, filters: opts }).to_json
  end

  def report_attributes
    case export_type
    when "json"
      json_attributes
    else
      send "#{app.report_template}_headers"
    end
  end

  def json_attributes
    { attrs: %I[detection_date value details] }
  end

  def generic_headers
    {
      attrs:         (
        %I[verdict detection_date] + [%I[device hostname]] + %I[value]
      ),
      header_values: %I[verdict detection_date device value]
    }
  end

  def hibp_headers
    {
      attrs:         (
        %I[verdict detection_date value] +
        [%I[details title]] +
        [%I[details domain]] +
        [%I[details pwncount]]
      ),
      header_values: %I[verdict detection_date email breach domain pwn_count]
    }
  end

  def ttp_headers
    {
      attrs:         (
        %I[verdict detection_date] + [%I[device hostname]] +
        %I[value] + [%I[ttp technique]]
      ),
      header_values: %I[verdict detection_date device filename technique]
    }
  end

  def passly_headers
    {
      attrs:         (
        %I[verdict detection_date] +
        [%I[customer name]] +
        %I[value_type] +
        %I[value] +
        [%I[details id]]
      ),
      header_values: %I[verdict detection_date customer_name record success id]
    }
  end

  def deep_instinct_headers
    {
      attrs:         (
        %I[verdict detection_date] +
        [%I[customer name]] +
        [%I[details last_action]] +
        %I[details_type] +
        [%I[details reoccurrence_count]] +
        %I[recorded_device_hostname]
      ),
      header_values: %I[verdict detection_date customer_name last_action type repeats hostname]
    }
  end

  def ironscales_headers
    {
      attrs:         (
        %I[verdict detection_date] +
        [%I[customer name]] +
        [%I[details sender_reputation]] +
        [%I[details sender_email]] +
        [%I[details senderemail]] +
        [%I[details sender_is_internal]] +
        [%I[details classification]] +
        [%I[details themis_verdict]]
      ),
      header_values: %I[verdict detection_date customer_name sender_reputation sender_email
                        report_sender_email sender_is_internal classification themis_verdict]
    }
  end

  def network_connection_headers
    {
      attrs:         (
        %I[verdict detection_date] +
        [%I[device hostname]] +
        [%I[details local_address]] +
        [%I[details local_port]] +
        [%I[details remote_address]] +
        [%I[details remote_port]] +
        [%I[details service_name]]
      ),
      header_values: %I[verdict detection_date device] +
        %I[local_ip local_port remote_ip remote_port] +
        %I[service]
    }
  end

  def cyberterrorist_network_connection_headers
    {
      attrs:         (
        %I[verdict detection_date] +
        [%I[device hostname]] +
        [%I[details local_address]] +
        [%I[details local_port]] +
        [%I[details remote_address]] +
        [%I[details remote_port]] +
        [%I[details direction]] +
        [%I[details detection_count]] +
        [%I[details country]]
      ),
      header_values: (
        %I[verdict detection_date hostname] +
        %I[local_ip local_port remote_ip remote_port] +
        %I[direction detection_count country]
      )
    }
  end

  def event_headers
    {
      attrs:         (
        %I[verdict detection_date] + [%I[device hostname]] +
        [%I[details event_id]] + [%I[details event_category]] + [%I[details log_name]]
      ),
      header_values: %I[verdict detection_date device event_id category source]
    }
  end

  def crypto_mining_headers
    {
      attrs:         (
        %I[verdict detection_date] + [%I[device hostname]] +
        [%I[details description]] + %I[value]
      ),
      header_values: %I[verdict detection_date device description value]
    }
  end

  def defender_headers
    {
      attrs:         (
        %I[verdict detection_date] + [%I[device hostname]] +
        [%I[details threat_name]] + [%I[details severity]]
      ),
      header_values: %I[verdict detection_date device threat severity]
    }
  end

  def bitdefender_headers
    {
      attrs:         (
        %I[verdict detection_date] +
        [%I[customer name]] +
        [%I[details threatname]] +
        [%I[details endpointip]] +
        [%I[details endpointname]]
      ),
      header_values: %I[verdict detection_date customer_name threat_name endpoint_ip endpoint_name]
    }
  end

  def secure_score_headers
    {
      attrs:         (
        %I[verdict detection_date value] +
        [{ details: %I[controlCategory] }] + [{ details: %I[score] }]
      ),
      header_values: %I[verdict detection_date control category current_score]
    }
  end

  def directory_audit_headers
    {
      attrs:         (
        %I[verdict detection_date] +
        [{ details: %I[activity description] }] + [{ details: %I[activity result] }]
      ),
      header_values: %I[verdict detection_date event result]
    }
  end

  def signin_headers
    {
      attrs:         (
        %I[verdict detection_date] +
        [%I[details username]] +
        [%I[details city]] + [%I[details state]] + [%I[details country]] +
        [%I[details detection_count]] + [%I[details login_attempt]]
      ),
      header_values: %I[verdict detection_date user city state country detection_count result]
    }
  end

  def data_discovery_headers
    {
      attrs:         (
        %I[verdict] + [%I[details file_name]] + %I[detection_date] + [%I[device hostname]] +
        [%I[details total_discoveries]] + [%I[details file_owner]]
      ),
      header_values: %I[verdict filename detection_date device discoveries owner]
    }
  end

  def sentinelone_headers
    {
      attrs:         (
        %I[verdict detection_date] +
        [%I[details agentcomputername]] +
        [%I[details threatname]] + [%I[details description]] +
        [%I[details mitigationstatus]] +
        [%I[details fileverificationtype]]
      ),
      header_values: %I[verdict detection_date device threat description status file_signed]
    }
  end

  def syslog_headers
    {
      attrs:         (
        %I[verdict detection_date] +
        [%I[details fw_mac_add]] + [%I[details local_port]] + [%I[details remote_port]] +
        [%I[details protocol]] + %I[value] + [%I[details country]]
      ),
      header_values: %I[verdict detection_date device local_port remote_port protocol type country]
    }
  end

  def webroot_headers
    {
      attrs:         (
        %I[verdict detection_date] +
        [%I[details hostname]] + [%I[details filename]] + [%I[details malwaregroup]]
      ),
      header_values: %I[verdict detection_date device threat type]
    }
  end

  def cylance_headers
    {
      attrs:         (
        %I[verdict detection_date] +
        [%I[details device_name]] + [%I[details threat_name]] +
        [%I[details file_status]] + [%I[details file_path]]
      ),
      header_values: %I[verdict detection_date device threat_name status file_path]
    }
  end

  def dns_filter_headers
    {
      attrs:         (
        %I[verdict detection_date value] +
        [%I[details fqdn]] + [%I[details categories]] + [%I[details result]]
      ),
      header_values: %I[verdict detection_date deployment fqdn category result]
    }
  end
end
