module TestResults
  # Represents a test result detail json/hash entry Process
  class ProcessJson < BaseJson
    IGNORED_ATTRS = %i[pe].freeze
    ORDER = %i[
      pid process_id process parent_process_id file_name file_path command_line user_name owner created
      md5 sha1 sha2 company_name orginal_file_name internal_name file_version
      product_version product_name size last_accessed create_time last_write_time
      threat_count file_attributes session_id connections running dir_name file_owner
      image_path parent_process parent
    ].freeze

    def parent_process?
      parent && parent.class.name == "TestResults::ProcessJson"
    end

    def process_tree
      @process_tree ||= parent_processes.reverse
    end

    def parent_processes
      return [self] unless parent_process?

      [self] + parent.parent_processes
    end
  end
end
