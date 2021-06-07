# Override devise error message format
module DeviseHelper
  def devise_error_messages!
    return "" if resource.errors.blank?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      count:    resource.errors.count,
                      resource: resource.class.model_name.human.downcase)

    html = <<-HTML
    <div class="alert alert-danger noborder nomargin noradius">
      <h5 class="alert-danger">#{sentence}</h5>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end
end
