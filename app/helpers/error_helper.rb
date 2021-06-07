# Simplifies logging errors
module ErrorHelper
  def html_error(file, resp, id = nil)
    if resp.code == 200 # TODO: add 201 and 209 as allowed?
      false
    else
      begin
        Rails.logger.error("HTML ERROR in file #{file} for #{id || '?'} with code #{resp.code}"\
          " and message #{JSON.parse(resp.raw_body)}")
      rescue JSON::ParserError
        Rails.logger.error("HTML ERROR in file #{file} for #{id || '?'} with code #{resp.code}"\
          " and message #{resp.raw_body}")
      end
      true
    end
  end

  def database_error(file, resp)
    if !resp.is_a?(ActiveRecord::Base) || resp.id.nil?
      begin
        Rails.logger.error("DB ERROR in file #{file} for object #{resp.to_json}")
      end
      true
    else
      false
    end
  end
end
