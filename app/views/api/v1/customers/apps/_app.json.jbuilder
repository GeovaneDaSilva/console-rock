json.extract! app, :id, :title, :description, :indicator, :price_cents, :price_currency,
              :report_template, :on_by_default, :configuration_type, :type, :platforms,
              :discreet, :configuration_scopes, :author

%w[upload display_image display_image_icon].each do |type|
  json.set! type do
    json.name app.send(type)&.filename
    json.version app.send(type)&.md5
    json.url app.send(type)&.url
  end
end
