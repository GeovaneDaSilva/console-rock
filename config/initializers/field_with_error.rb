ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  if /class=/ =~ html_tag
    html_tag.gsub!(/class="/, %(class="error ))
  else
    html_tag.gsub!(/\/>/, %( class="error"\/>))
  end

  html_tag.html_safe
end
