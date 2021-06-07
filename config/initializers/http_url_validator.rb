# Validate the value is URL-lik
class HttpUrlValidator < ActiveModel::EachValidator
  def self.compliant?(value)
    uri = URI.parse(value)
    uri.host.present?
  rescue URI::InvalidURIError
    false
  end

  def validate_each(record, attribute, value)
    return if value.blank?
    return if self.class.compliant?(value)

    record.errors.add(attribute, "is not a valid URL")
  end
end
