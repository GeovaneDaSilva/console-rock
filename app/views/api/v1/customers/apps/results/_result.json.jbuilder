json.extract!(result, :verdict, :detection_date, :value, :value_type, :type)
json.details result.read_attribute :details
