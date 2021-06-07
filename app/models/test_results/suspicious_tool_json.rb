module TestResults
  # Represents a test result detail json/hash entry SuspiciousTool
  class SuspiciousToolJson < BaseJson
    ORDER = %i[
      description category full_path file_name md5 sha1 sha2 created
      accessed modified last_seen size attributes
    ].freeze

    def path
      full_path_without_file_name || displayicon_path || uninstallstring_path
    end

    def full_path_without_file_name
      return if full_path.blank?

      paths = full_path.split("\\")
      paths[0..(paths.length - 2)].join("\\")
    end

    def displayicon_path
      return if displayicon.blank?

      paths = displayicon.split("\\")
      paths[0..(paths.length - 2)].join("\\")
    end

    def uninstallstring_path
      return if uninstallstring.blank?

      paths = uninstallstring.split("\\")
      paths[0..(paths.length - 2)].join("\\").gsub(/"/, "")
    end
  end
end
