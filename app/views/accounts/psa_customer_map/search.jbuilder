json.customers form.query.customers do |customer|
  json.id customer.id
  json.name customer.name
  json.cached_company do
    company = customer.cached_company
    if company
      json.id company.id
      json.name company.name
    else
      json.nil!
    end
  end
end

json.companies form.query.companies do |company|
  json.id company.id
  json.name company.name
end

json.company_types form.query.company_types do |company_type|
  json.id company_type.id
  json.name company_type.name
end
