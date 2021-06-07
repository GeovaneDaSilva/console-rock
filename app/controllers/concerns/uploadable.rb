# Common controller methods to support uploading attached to a resource
# The controller which includes this should specify these private methods
#
# def create_upload!
#   # Authorization & create the upload, assigning it to @upload
# end
#
# def upload_url
#   # URL where the Upload lives, where actions can be taken on it
#   # Not to be confused with the download_url
# end
module Uploadable
  extend ActiveSupport::Concern

  included do
    before_action :find_upload, except: [:create]
  end

  def create
    create_upload!

    render json: signature
  end

  def update
    authorize @upload if respond_to?(:authorize, @upload)

    @upload.completed!

    render json: json
  end

  def show
    authorize @upload if respond_to?(:authorize, @upload)

    render json: json
  end

  def destroy
    authorize @upload if respond_to?(:authorize, @upload)

    @upload.trashed!

    head :ok
  end

  private

  def upload_params
    params.permit(upload_params_keys)
  end

  def upload_params_keys
    %i[
      filename
      size
    ] << { tags: [] }
  end

  def signature
    signature = @upload.bucket.presigned_post(signature_options)

    {
      id:          @upload.id,
      url:         signature.url,
      fields:      signature.fields,
      resourceUrl: upload_url
    }
  end

  def signature_options
    {
      key:                  @upload.key,
      acl:                  acl,
      content_length_range: filesize,
      content_encoding:     params[:encoding],
      content_type:         @upload.mime_type.to_s,
      metadata:             { tags: @upload.tags }
    }.reject { |_, v| v.blank? }
  end

  def filesize
    0..5.megabytes
  end

  def json
    {
      url:         download_url,
      key:         @upload.key,
      id:          @upload.id,
      resourceUrl: upload_url,
      filename:    @upload.filename
    }
  end

  def find_upload
    @upload ||= Upload.find(params[:id])
  end

  def download_url
    @upload.url
  end

  def acl
    "private"
  end
end
