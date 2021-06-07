module TestResults
  # Represents a test result detail json/hash entry Malicious File Detection
  class MaliciousFileDetectionJson < BaseJson
    IGNORED_ATTRS = %i[pe].freeze
    ORDER = %i[
      verdict file_name file_path dir_name file_size md5 sha1 sha2 created accessed modified
      request_time attributes static_analysis
    ].freeze
  end
end
