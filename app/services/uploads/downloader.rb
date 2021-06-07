module Uploads
  # Download an upload and inflate if necessary
  class Downloader
    def initialize(upload)
      @upload = upload
    end

    def call
      case @upload.mime_type
      when Mime::Type.lookup("application/x-deflate")
        inflate_file
      else
        case @upload.object.content_encoding
        when "gzip"
          decompress_file
        else
          file
        end
      end
    end

    private

    def file
      return @file if @file

      @file = Tempfile.new(@upload.filename, encoding: "ascii-8bit")
      @upload.object.get(response_target: @file)

      @file.rewind
      @file
    end

    def inflate_file
      uncompressed = Tempfile.new(@upload.filename, encoding: "ascii-8bit")
      Zlib::Inflate.inflate(file.read) do |chunk|
        uncompressed.write(chunk)
      end

      uncompressed.rewind
      uncompressed
    end

    def decompress_file
      decompressed = Tempfile.new(@upload.filename, encoding: "ascii-8bit")
      Zlib::GzipReader.open(file) do |gz|
        decompressed.write(gz.read)
      end

      decompressed.rewind
      decompressed
    end
  end
end
