if @result.errors?
  json.errors @result.errors do |error|
    json.error(error)
  end
end
