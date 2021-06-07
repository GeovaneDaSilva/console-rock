module Seeds
  # seed app results from staging
  class AppResults
    def call
      @base_url = "https://staging.rocketcyber.com/api/customers"

      HTTPI.log   = false

      app_results = make_app_results

      Customer.all.each do |customer|
        app_results.keys.each do |app_id|
          app_results[app_id].each do |ar_attrs|
            ar = ::Apps::Result.new(
              device_id: customer.devices.sample, type: ar_attrs["type"],
              app_id: app_id, customer_id: customer.id, account_path: customer.path
            )

            ar.assign_attributes ar_attrs.except("id")
            ar.device_id = customer.devices.sample.id if ar.is_a?(::Apps::DeviceResult)
            ar.save!
          end
        end
      end
    end

    private

    def fetch_apps
      apps_url = "#{@base_url}/#{ENV['STAGING_LICENSE_KEY']}/apps"

      apps = []

      response = HTTPI.get(apps_url)
      apps_json = JSON.parse(response.body)
      apps_json["apps"].each { |app| apps << app }

      if apps_json["total_pages"] > 1
        (2..apps_json["total_pages"]).each do |page|
          response = HTTPI.get("#{apps_url}?page=#{page}")
          apps_json = JSON.parse(response.body)

          apps_json["apps"].each { |app| app_ids << app.id }
        end
      end

      apps
    end

    def make_app_results
      apps = fetch_apps

      hash = {}
      apps.each do |app|
        local_app = App.where(title: app["title"], description: app["description"]).first

        app_results_url = "#{@base_url}/#{ENV['STAGING_LICENSE_KEY']}/apps/#{app['id']}/results"

        response = HTTPI.get(app_results_url)
        app_results_json = JSON.parse(response.body)

        hash[local_app.id] = app_results_json["app_results"]
      end

      hash
    end
  end
end
