class UpdateCtnConfigExcludedIps < ActiveRecord::Migration[5.2]
  def up
    Apps::Config.joins(:app).where(apps: { report_template: :cyberterrorist_network_connection }).find_each do |app_config|
      app_config.update(
        config: app_config.config.tap { |config| config["excluded_ips"] = config.fetch("excluded_ips", "").split("\n") }
      )
    end
  end

  def down
    Apps::Config.joins(:app).where(apps: { report_template: :cyberterrorist_network_connection }).find_each do |app_config|
      app_config.update(
        config: app_config.config.tap { |config| config["excluded_ips"] = config.fetch("excluded_ips", "").join("\n") }
      )
    end
  end
end
