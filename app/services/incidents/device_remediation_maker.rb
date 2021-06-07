# :nodoc
module Incidents
  # :nodoc
  class DeviceRemediationMaker
    class DBError < StandardError; end
    class MapError < StandardError; end

    # TODO: I want to make a lookup I only have to create once.
    # ...basically, I want a database that stays in memory and I don't have to hit the DB every time:
    # i.e. a cache for the app IDs associated with certain pieces of information.
    # HOW to force creation/persistence of such a thing?
    def self.generate_remediation_object(app_result, remediation_id)
      raise DBError, "initial check" unless app_result.is_a?(Apps::Result) && !remediation_id.nil?

      @app_id = app_result.app_id
      @action_index = 1
      @generate_map = {
        App.find_by(configuration_type: "advanced_breach_detection").id => "generate_advanced_breach_detection_remediation",
        App.find_by(configuration_type: "malicious_file_detection").id  => "generate_malicious_file_remediation",
        App.find_by(configuration_type: "suspicious_tools").id          => "generate_suspicious_tools_remediation",

        App.find_by(configuration_type: "defender").id                  => "generate_defender_remediation"
      }

      # TODO: how to make short description?
      {
        type:    "remediate",
        payload: {
          app_id:              @app_id,
          isolate:             false,
          defender_full_scan:  @generate_map[@app_id] == "generate_defender_remediation",
          remediation_id:      remediation_id,
          remediation_actions: send(@generate_map[@app_id], app_result)
        }
      }
    rescue NoMethodError => e
      raise DBError, e.message
    rescue TypeError => e
      raise MapError, e.message
    end

    def self.generate_remediation_action(index, type, path, action, abort)
      {
        order:         index,
        type:          type,
        file_path:     path,
        action:        action,
        abort_on_fail: abort
      }
    end

    def self.generate_registry_remediation_action(index, key, value, abort)
      {
        order:         index,
        type:          "reg",
        key:           key,
        key_value:     value,
        action:        "delete",
        abort_on_fail: abort
      }
    end

    def self.create_short_summary(remedation); end

    def self.generate_advanced_breach_detection_remediation(app_result)
      return if app_result["details"].nil?

      attributes = app_result["details"]["attributes"]
      return if attributes.nil?

      case app_result["details"].dig("type")
      when "AdvancedBreachDetection"
        remediations = []
        process = attributes.dig("process", "attributes")
        target_image = process.dig("target_image")
        if target_image.blank?
          file_path = process.dig("file_path")
          process_action = generate_remediation_action(1, "process", file_path, "terminate", false)
          file_action = generate_remediation_action(2, "file", file_path, "delete", false)
          return [process_action, file_action]
        else
          target_image.each do |file|
            file_path = file.dig("attributes", "file_path")
            process_action = generate_remediation_action(@action_index, "process", file_path, "terminate", false)
            @action_index += 1
            file_action = generate_remediation_action(@action_index, "file", file_path, "delete", false)
            @action_index += 1
            remediations << process_action
            remediations << file_action
          end
        end

        remediations
      when "TTP_Registry_Change"
        return if attributes.dig("file_object").nil?

        key = attributes.dig("registry_path")
        key_value = attributes.dig("registry_value")
        file_path = attributes.dig("file_object", "file_path")

        return if key.nil? || key_value.nil? || file_path.nil?

        reg_action = generate_registry_remediation_action(1, key, key_value, true)
        process_action = generate_remediation_action(2, "process", file_path, "terminate", false)
        file_action = generate_remediation_action(3, "file", file_path, "delete", false)

        [reg_action, process_action, file_action]
      else
        # covers "Persistence" and "Registry Run Keys"
        file_path = attributes.dig("persistent_location", "file_path")
        registry_key = attributes.dig("persistent_location", "registry_key")
        registry_value = attributes.dig("persistent_location", "registry_value")
        # registry_value_data = attributes.dig("persistent_location", "registry_value_data")

        registry_action	= generate_registry_remediation_action(1, registry_key, registry_value, true)
        # executable_action = generate_remediation_action(2, entry_type, file_path, "terminate", false)
        # TODO: is there really a possibility for this "entry_type" (above) to be something other than a registry key?
        executable_action = generate_remediation_action(2, "registry", file_path, "terminate", false)
        file_action = generate_remediation_action(3, "file", file_path, "delete", false)
        [registry_action, executable_action, file_action]
      end
    end
    # TODO: Rob had a bunch of different options other than "persistent_location", but my check shows that
    # all existing records of "Persistence" or "Registry Run Keys" types have "persistent_location"

    def self.generate_malicious_file_remediation(app_result)
      return if app_result["details"].nil?

      attributes = app_result["details"]["attributes"]
      return if attributes.nil?

      if attributes["key"].nil?
        # this is NOT a registry key result, it is a file-based detection
        action = generate_remediation_action(1, "file", attributes["file_path"], "delete", false)
        [action]
      else
        # this IS a registry key result
        key = attributes["key"]
        key_value = attributes["key_value"]
        file_path = attributes["file_path"]

        unless key.nil? || key_value.nil? || file_path.nil?
          reg_action = generate_registry_remediation_action(1, key, key_value, true)
          # false because the process may not be running
          process_action = generate_remediation_action(2, "process", file_path, "terminate", false)
          file_action = generate_remediation_action(3, "file", file_path, "delete", false)
          [reg_action, process_action, file_action]
        end
      end
    end

    def self.generate_suspicious_tools_remediation(app_result)
      return if app_result["details"].nil?

      attributes = app_result["details"]["attributes"]
      return if attributes.nil?

      remediations = []
      if !attributes["UninstallString"].nil?
        action = generate_remediation_action(@action_index, "uninstall", attributes["UninstallString"], "uninstall", true)
        remediations << action
        @action_index += 1
      elsif !attributes["full_path"].nil?
        file_path = attributes["full_path"]
        action = generate_remediation_action(@action_index, "file", file_path, "delete", true)
        remediations << action
        @action_index += 1
      elsif !(attributes["dir_name"].nil? || attributes["file_name"].nil?)
        file_path = attributes["dir_name"] + attributes["file_name"]
        action = generate_remediation_action(@action_index, "file", file_path, "delete", true)
        remediations << action
        @action_index += 1
      elsif !attributes["files"].nil?
        attributes["files"].each do |file|
          next if file.dig("attributes", "dir_name").nil? || file.dig("attributes", "file_name").nil?

          file_path = file.dig("attributes", "dir_name") + file.dig("attributes", "file_name")
          action = generate_remediation_action(@action_index, "file", file_path, "delete", true)
          remediations << action
          @action_index += 1
        end
      else
        return
      end

      remediations
    end

    def self.generate_defender_remediation(app_result)
      return if app_result["details"].nil?

      attributes = app_result["details"]["attributes"]
      return if attributes.nil? || attributes["files"].nil?

      remediations = []

      attributes["files"].each do |file|
        file_path = file_path(file)
        next if file_path.nil?

        action = generate_remediation_action(@action_index, "file", file_path, "delete", true)
        remediations << action
        @action_index += 1
      end

      remediations
    end

    def self.file_path(file)
      if file.is_a? Hash
        return nil if file.dig("attributes", "dir_name").nil? || file.dig("attributes", "file_name").nil?

        return file.dig("attributes", "dir_name") + file.dig("attributes", "file_name")
      end
      file
    end
  end
end
