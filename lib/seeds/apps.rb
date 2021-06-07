module Seeds
  # seeds apps from staging
  class Apps
    def call
      HTTPI.log = false

      license_key = ENV["STAGING_LICENSE_KEY"]
      apps_url    = "https://staging.rocketcyber.com/api/customers/#{license_key}/apps"
      apps_response = HTTPI.get(apps_url)
      apps_json = JSON.parse(apps_response.body)

      puts "#{apps_json['total_count']} apps found on staging..."

      apps_json["apps"].each { |app| process(app) }

      return unless apps_json["total_pages"] > 1

      (2..apps_json["total_pages"]).each do |page|
        paged_app_json = JSON.parse(HTTPI.get("#{apps_url}?page=#{page}"))

        paged_app_json["apps"].each { |app| process(app) }
      end
    end

    private

    def process(app_attrs)
      whitelisted = %w[description indicator price_cents price_currency
                       report_template on_by_default configuration_type type]

      app = ::App.where(title: app_attrs["title"]).first_or_initialize do |initialized_app|
        initialized_app.assign_attributes app_attrs.extract!(*whitelisted)
      end

      script             = app_attrs["upload"]
      display_image      = app_attrs["display_image"]
      display_image_icon = app_attrs["display_image_icon"]

      script_upload             = make_upload(script["name"], script["url"])
      display_image_upload      = make_upload(display_image["name"], display_image["url"])
      display_image_icon_upload = make_upload(display_image_icon["name"], display_image_icon["url"])

      app.upload_id             = script_upload&.id if app.respond_to?(:upload)
      app.display_image_id      = display_image_upload&.id
      app.display_image_id      = display_image_upload&.id
      app.display_image_icon_id = display_image_icon_upload&.id
      app.author                = app_attrs["author"]
      app.platforms             = app_attrs["platforms"]
      app.discreet              = app_attrs["discreet"]
      app.configuration_scopes  = app_attrs["configuration_scopes"]

      complete(app)
    end

    def make_upload(filename, url)
      return nil unless filename && url

      local_upload = Upload.find_by(filename: filename)
      latest_etag = local_upload&.md5

      file = Tempfile.new(filename)
      file.binmode

      request = HTTPI::Request.new(url: url, open_timeout: 15)
      request.headers["If-None-Match"] = latest_etag

      request.on_body do |body|
        body.each_byte { |byte| file.print byte.chr }
      end

      response = HTTPI.get(request)
      file.close

      handle_response(response, file, filename, local_upload)
    end

    def handle_response(response, file, filename, local_upload)
      if response.code == 200
        puts "Uploading #{filename}."
        Uploads::Builder.new(file.path, filename: filename, protected: true).call
      elsif response.code == 304
        puts "Latest version of #{filename} already exists. Skipping upload."
        local_upload
      else
        puts "Unable to download #{filename}. HTTP status: #{response.code}"
      end
    end

    def complete(app)
      if app.save
        puts "#{app.title} successfully saved!"
      else
        puts "#{app.title} unable to save: #{app.errors.messages}"
      end
    end
  end
end
