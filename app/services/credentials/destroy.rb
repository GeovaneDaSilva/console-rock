# :nodoc
module Credentials
  # Destroy a credential.  This is a separate service because with the large number of
  # dependent app results, the destroy operation can take hours (although should not usually)
  # This allows the entire process to take place in the background, thus not hanging the UI,
  # and it is a low priority call, so it will not be carried out if system is busy.
  class Destroy
    def initialize(cred_id)
      @cred = Credential.find(cred_id)
    rescue ActiveRecord::RecordNotFound
      @cred = nil
    end

    def call
      return if @cred.nil? || !@cred.is_a?(Credential)

      delete_ms_graph if @cred.is_a?(Credentials::MsGraph)

      # This is causing problems with customers removing/re-adding credentials due to some type of
      # problem and having to redo all their AV mappings.  Will change this to a scheduled job that
      # finds AV mappings that do not correlate to any existing credential and remove.
      # delete_antivirus_customer_maps
      if @cred.is_a?(Credentials::Datto) || @cred.is_a?(Credentials::Connectwise) ||
         @cred.is_a?(Credentials::Syncro) || @cred.is_a?(Credentials::Kaseya)
        delete_psa_integrations
      end

      @cred.destroy
    end

    def delete_ms_graph
      # BillableInstance.where(line_item_type: "office_365_mailbox", account_path: @cred.account.path)
      #                 .where("created_at > ?", 1.day.ago).destroy_all
      #
      # BillableInstance.where(line_item_type: "office_365_mailbox", account_path: @cred.account.path)
      #                 .where("created_at < ?", 1.day.ago).update_all(active: false)

      AccountApp.joins(:app).where(disabled_at: nil, account_id: @cred.customer_id,
        apps: { type: "Apps::Office365App" }).where.not(enabled_at: nil).update_all(last_pull: nil)
    end

    # def delete_antivirus_customer_maps
    #   app_id = find_credentials_app
    #   return if app_id.nil?
    #
    #   account_ids = @cred.account.self_and_all_descendants.pluck(:id)
    #
    #   AntivirusCustomerMap.where(app_id: app_id, account_id: account_ids).destroy_all
    # end

    def find_credentials_app
      return nil if @cred.is_a?(Credentials::MsGraph)

      config_type = nil

      if @cred.is_a?(Credentials::Sentinelone)
        config_type = "sentinelone"
      elsif @cred.is_a?(Credentials::Bitdefender)
        config_type = "bitdefender"
      elsif @cred.is_a?(Credentials::Cylance)
        config_type = "cylance"
      elsif @cred.is_a?(Credentials::Webroot)
        config_type = "webroot"
      elsif @cred.is_a?(Credentials::Ironscales)
        config_type = "ironscales"
      else
        return nil
      end

      App.find_by(configuration_type: config_type)&.id
    end

    def delete_psa_integrations
      psa_config = PsaConfig.find_by(account_id: @cred.account_id)
      return if psa_config.nil?

      psa_config.destroy if psa_config.psa_type && @cred.type.include?(psa_config.psa_type)
      Credential.where(type: @cred.type, account_id: @cred.account_id)
                .where.not(id: @cred.id).destroy_all
    end
  end
end
