module TestResults
  # Represents a test result detail json/hash entry File
  class FileJson < BaseJson
    ORDER = %i[
      file_name dir_name md5 sha1 sha2 size last_accessed attributes
    ].freeze
  end
end
