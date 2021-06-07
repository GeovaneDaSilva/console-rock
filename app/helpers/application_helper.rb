# :nodoc
module ApplicationHelper
  include Pagy::Frontend
  include Pagy::Backend

  def gravatar_url(email)
    hash = Digest::MD5.hexdigest(email)
    "https://www.gravatar.com/avatar/#{hash}"
  end

  def page_header(title, crumbs = [])
    title_tag = content_tag(:h1, title) unless title.nil?

    safe_join([title_tag, breadcrumbs_tag(crumbs)])
  end

  def active_path?(path)
    case path
    when String
      request.fullpath == path
    when Regexp
      request.fullpath =~ path
    end
  end

  def breadcrumbs_tag(breadcrumbs)
    content_tag :ol, class: "breadcrumb" do
      crumbs = breadcrumbs.collect do |crumb|
        klass = "active" if crumb == breadcrumbs.last
        content_tag(:li, crumb, class: [klass])
      end

      safe_join(crumbs)
    end
  end

  def link_to_current_account(name, html_options = {}, &block)
    link_to_account name, current_account, html_options, &block
  end

  def link_to_account(name, account, html_options = {}, &block)
    url = case account
          when Provider
            provider_path(account)
          when Customer
            customer_path(account)
          end

    link_to name, url, html_options, &block
  end

  def yesno(value)
    value ? "Yes" : "No"
  end

  def danger_or_success_class(count, breaking_point = 0, bit = 1)
    (count * bit) >= breaking_point ? "txt-success" : "txt-danger"
  end

  def success_or_exclamation_class(count, breaking_point = 0, bit = 1)
    (count * bit) >= breaking_point ? "fa-check-circle" : "fa-exclamation-triangle"
  end

  def report_scope(group)
    if group.persisted?
      group.name
    else
      "All Devices for #{current_account.name}"
    end
  end

  def inline_loader(opts = {})
    content_tag :div, opts.merge(class: "inline-loader loading") do
      safe_join(
        [
          content_tag(:div, "", class: "bounce1"),
          content_tag(:div, "", class: "bounce2"),
          content_tag(:div, "", class: "bounce3")
        ]
      )
    end
  end

  def days_since(end_date, start_date)
    ((end_date.to_f - start_date.to_f).to_f / 1.day).floor
  end

  def number_with_delimiter_or_dash(number)
    number.to_i < 1 ? "-" : number_with_delimiter(number)
  end

  def signed_env_var(variable)
    OpenSSL::HMAC.hexdigest("sha256", ENV["SECRET_KEY_BASE"].to_s, ENV.fetch(variable, ""))
  end

  def prettify(string)
    case string
    when /url/i
      "URL"
    when /filehash/i
      "Hash"
    when /processname/i
      "Process"
    else
      string
    end
  end

  def credit_card_icon(card_type)
    case card_type&.parameterize
    when "american-express"
      "fa-cc-amex"
    when "visa"
      "fa-cc-visa"
    when "mastercard"
      "fa-cc-mastercard"
    when "discover"
      "fa-cc-discover"
    else
      "fa-credit-card"
    end
  end

  def link_url(url)
    URI.parse(url)

    link_to url, url, rel: "nofollow noopener", target: "_blank"
  rescue URI::Error
    url
  end

  def defender_action_icon(action)
    case action.parameterize
    when "quarantine"
      "fa fa-exclamation-triangle"
    when "remove"
      "fa fa-trash"
    when "allow"
      "fa fa-thumbs-o-up"
    end
  end

  def finding_text_class(state)
    case state
    when "malicious"
      "text-danger"
    when "suspicious"
      "text-warning"
    when "informational"
      "text-info"
    end
  end

  def action_state_icon(state)
    case state
    when "requested"
      "fa fa-spinner"
    when "resolved"
      "fa fa-thumbs-o-up"
    when "errored"
      "fa fa-times-circle"
    end
  end

  def defender_action_class(action)
    case action.parameterize
    when "quarantine"
      "text-warning"
    when "remove"
      "text-danger"
    when "allow"
      "text-success"
    end
  end

  def parsed_time(time_string, fallback = DateTime.current)
    Time.parse(time_string).utc
  rescue ArgumentError
    fallback
  end

  def to_sentence_with_max(array, max = 3, *opts)
    if array.length > max
      limited = array.take(max)
      remaining = array.length - max
      limited << "#{remaining} #{'other'.pluralize(remaining)}"
      limited.to_sentence(*opts)
    else
      array.to_sentence(*opts)
    end
  end

  def icon_for_account(account)
    if account.provider?
      account.distributor? ? "fa-sitemap" : "fa-building-o"
    elsif account.customer?
      "fa-users"
    end
  end

  def gzip_string(str)
    gz = Zlib::GzipWriter.new(StringIO.new)
    gz << str
    gz.close.string
  end

  def icon_for_platform(platform, klasses = "")
    case platform
    when "windows"
      content_tag :i, "", class: "fa fa-windows #{klasses}", alt: "Windows"
    when "macos"
      content_tag :i, "", class: "fa fa-apple #{klasses}", alt: "MacOS"
    end
  end

  def render_with_allowed_tags(text, opts = {})
    opts[:tags] ||= %w[b i a li]
    simple_format sanitize(text, tags: opts[:tags])
  end

  # NOTE: rubocop is complaining here because using instance variables makes helpers more
  # difficult to reuse on other controllers. That does not apply in this case because
  # the variable is not required to be set prior to being called here. It's entire
  # lifecycle is handled by this method.

  # rubocop:disable Rails/HelperInstanceVariable
  def with_stimulus_controller(name)
    original_stimulus_controller = @stimulus_controller || nil
    @stimulus_controller = name
    yield
    @stimulus_controller = original_stimulus_controller
  end
  # rubocop:enable Rails/HelperInstanceVariable

  attr_reader :stimulus_controller

  def stimulus_target(target)
    "#{stimulus_controller}.#{target}"
  end

  def stimulus_action(action, method)
    "#{action}->#{stimulus_controller}##{method}"
  end

  def mask(str)
    str&.gsub(/.(?=.{4})/, "*")
  end

  def masked?(str)
    return false if str.blank?

    str = str[0..-5] if str.length > 4
    (str =~ /[^\*]/).nil?
  end
end
