# :nodoc
module TriageScopeable
  include Pagy::Backend

  def app_results
    raise NotImplementedError
  end

  def total_count
    @total_count ||= app_counter_caches.sum(:count)
  end

  def similar_detections
    # This is a hack to see if CyberTerror app will load if there are fewer results.
    # if defined?(current_user) && current_user&.admin?
    paginate_similar_detections
    # else
    #   page_size = app.configuration_type == "cyberterrorist_network_connection" ? 15 : 30
    #   @similar_detections = filtered_app_results.order("detection_date DESC")
    #                                             .page(params[:page]).per(page_size)
    #
    #   if !filters?
    #     # Oh boy, this is a hack to prevent Kaminari from counting the world
    #     # Note the double paging
    #     Kaminari.paginate_array(
    #       @similar_detections, total_count: total_count
    #     ).page(params[:page]).per(page_size)
    #   else
    #     @similar_detections
    #   end
    # end
  end

  def paginate_similar_detections
    # This is a hack to see if CyberTerror app will load if there are fewer results.
    # At present it is consistently timing out for certain accounts.
    page_size = app.configuration_type == "cyberterrorist_network_connection" ? 15 : 30

    if !filters?
      pagy filtered_app_results.order("detection_date DESC"), count: total_count, items: page_size
    else
      pagy filtered_app_results.order("detection_date DESC"), items: page_size
    end
  end

  def filtered_app_results
    results = app_results.where(app: app)
    results = params[:incident_id].present? ? results.with_incident : results.without_incident
    results = results.details_ilike(params[:search].gsub(/\\/, "\\\\\\")) if params[:search].present?
    results = results.where("detection_date >= ?", start_date) if start_date
    results = results.where("detection_date <= ?", end_date) if end_date
    results
  end

  def selected_app_results
    if params[:apply_to_all_similar] == "true"
      filtered_app_results.order("detection_date DESC")
    elsif params[:app_results].present?
      filtered_app_results.order("detection_date DESC").where(id: params["app_results"])
    else
      filtered_app_results.order("detection_date DESC")
    end
  end

  def filters?
    start_date.present? || end_date.present? || params[:search].present?
  end

  def start_date
    return @start_date unless @start_date.nil?

    time = Time.strptime(params[:start_date], "%m/%d/%Y")
    time = time.ctime.in_time_zone(current_user_timezone) if current_user_timezone
    @start_date ||= time.to_datetime.beginning_of_day
  rescue ArgumentError, TypeError
    nil
  end

  def end_date
    return @end_date unless @end_date.nil?

    time = Time.strptime(params[:end_date], "%m/%d/%Y")
    time = time.ctime.in_time_zone(current_user_timezone) if current_user_timezone

    @end_date ||= time.to_datetime.end_of_day
  rescue ArgumentError, TypeError
    nil
  end

  def app_counter_caches
    raise NotImplementedError
  end

  def current_user_timezone
    current_user&.timezone
  rescue NameError
    nil
  end
end
