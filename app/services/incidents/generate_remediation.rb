# :nodoc
module Incidents
  # :nodoc
  class GenerateRemediation
    include ErrorHelper

    def initialize(app_result_id, remediation_plan_id)
      @app_result = Apps::Result.find(app_result_id)
      # TODO: ^^ .includes(:app) ???
      @remediation_plan = RemediationPlan.find(remediation_plan_id)
      @remediation_plan_id = remediation_plan_id if @app_result.account_path == @remediation_plan.account_path
      # @firewall = @app_result.app.configuration_type == "syslog"
    rescue ActiveRecord::RecordNotFound
      @app_result = nil
    end

    def call
      return if @app_result.nil? || @remediation_plan_id.nil?

      if @app_result.app.configuration_type == "advanced_breach_detection"
        return if EXCLUDED_REMEDIATIONS[:advanced_breach_detection].include?(@app_result.details.ttp_id)
      end

      # if @firewall
      #   make_firewall_remediation
      # elsif @app_result.is_a?(Apps::DeviceResult)
      if @app_result.is_a?(Apps::DeviceResult)
        make_device_remediation
      elsif @app_result.is_a?(Apps::CloudResult)
        make_cloud_remediation
      end
    end

    private

    def make_device_remediation
      remediation = RemediationTypes::Device.new(
        result_id:           @app_result.id,
        status:              0,
        target_id:           @app_result.device_id,
        remediation_plan_id: @remediation_plan_id
      )
      remediation.save
      return if database_error(__FILE__, remediation)

      remediation_actions = nil
      begin
        remediation_actions = Incidents::DeviceRemediationMaker.generate_remediation_object(@app_result, remediation.id)
      rescue Incidents::DeviceRemediationMaker::DBError, Incidents::DeviceRemediationMaker::MapError => e
        Rails.logger.error("DeviceRemediationMaker Failure, #{e}")
        remediation_actions = nil
      end
      if remediation_actions.blank?
        remediation.destroy
        return
      end

      duplicate_check = Digest::MD5.hexdigest(@app_result.device_id.to_s + remediation_actions.to_json)
      return unless Remediation.find_by(duplicate_check: duplicate_check).nil?

      remediation.assign_attributes(
        duplicate_check: duplicate_check,
        actions:         remediation_actions
      )
      Rails.logger.error("Problem saving remediation #{remediation.id}") unless remediation.save
    end

    def make_cloud_remediation
      # raise NotImplementedError
      # Rails.logger.info("Attempted to make a cloud remediation -- not supported")

      # remediation_actions = Incidents::CloudRemediationMaker.generate_remediation_object(@app_result)
      #
      # new_record = RemediationTypes::Cloud.new(
      #   app_result_id: @app_result.id,
      #   status: 0, # needs to be string?
      #   remediation_plan_id: @remediation_plan_id,
      #   target_id: @app_result.device_id, ??? need billable_instance external_id (??)
      #   actions: remediation_actions
      # )
      #
      # if new_record.save
      #   # hooray!
      # else
      #   # ...what do I do if this fails?
      # end
    end

    def make_firewall_remediation
      # raise NotImplementedError
      # Rails.logger.info("Attempted to make a firewall remediation -- not supported")

      # remediation_actions = Incidents::FirewallRemediationMaker.generate_remediation_object(@app_result)
      #
      # new_record = RemediationTypes::Firewall.new(
      #   app_result_id: @app_result.id,
      #   status: 0, # needs to be string?
      #   remediation_plan_id: @remediation_plan_id,
      #   target_id: @app_result.device_id, <-- this device should be right, because the app comes from the
      #   monitoring machine
      #   actions: remediation_actions
      # )
      #
      # if new_record.save
      #   # hooray!
      # else
      #   # ...what do I do if this fails?
      # end
    end

    def failure_action
      @failure_action ||= {
        type:    "remediate",
        payload: {
          remediation_actions: {
            action:    "CREATION FAILURE",
            file_path: "- No remediation"
          }
        }
      }
    end
  end
end
