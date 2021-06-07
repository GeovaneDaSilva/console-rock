module Uploads
  # Upload a local file and create an Upload record appropriately
  class Builder
    def initialize(filename, attrs = {})
      @filename = filename
      @attrs = attrs
    end

    def call
      upload = ::Upload.create(upload_attributes)
      upload.bucket.put_object(
        acl:          acl,
        body:         file,
        key:          upload.key,
        content_type: upload.mime_type.to_s
      )
      upload.completed!

      upload
    end

    private

    def file
      @file ||= File.open(@filename)
    end

    def upload_attributes
      {
        filename: @filename.split("/").last,
        size:     file.size
      }.merge(@attrs)
    end

    def acl
      @attrs[:protected] ? "private" : "public-read"
    end
  end
end
