# Accepts a service, with arguments, to invoke, which returns a file object
# Upload the resulting file with given params
# Returns a URL for the upload
class ServiceGeneratedUploader
  def initialize(service_klass_name, service_args = [], upload_attributes = {})
    @service_klass_name = service_klass_name
    @service_args       = service_args
    @upload_attributes  = upload_attributes
  end

  def call
    Uploads::Builder.new(file.path, @upload_attributes).call.url
  end

  private

  def file
    @file ||= service_klass.new(*@service_args).call
  end

  def service_klass
    @service_klass_name.constantize
  end
end
