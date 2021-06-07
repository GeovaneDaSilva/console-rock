module Apps
  module Results
    # Saves Custom Whitelist for app results
    class CustomDestroyer
      def initialize(custom_config_id, account_id, app_id)
        @config = Apps::CustomConfig.find(custom_config_id)
        @app_results = Account.find(account_id).all_descendant_app_results.where(app_id: app_id)
        @config_list = @config.config["list"]
      rescue ActiveRecord::RecordNotFound
        @config = nil
      end

      def call
        return if @config.nil? || @config_list.blank?

        destroy_list = []
        @app_results.each do |result|
          @config_list.each do |ruleset|
            delete = true
            ruleset.each do |key, value|
              path = key.split(",")
              values = value.split(",")
              next if result["details"].dig(*path).to_s == value ||
                      (values.class == Array && values.include?(result["details"].dig(*path).to_s))

              delete = false
              break
            end

            if delete
              destroy_list << result.id
              break
            end
          end
        end

        @app_results.where(id: destroy_list).map(&:destroy)
      end
    end
  end
end
