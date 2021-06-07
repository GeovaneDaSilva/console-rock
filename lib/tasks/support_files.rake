namespace :support_files do
  desc "Updates support files"
  task update: :environment do
    HTTPI.log   = false

    license_key = ENV["STAGING_LICENSE_KEY"]
    all_files_url = "https://staging.rocketcyber.com/api/customers/#{license_key}/supports"
    all_files_api_response = HTTPI.get(all_files_url)
    all_files_json = JSON.parse(all_files_api_response.body)

    support_files = all_files_json["support_files"].collect do |support_file|
      latest_etag = Upload.support_files.completed.reorder("created_at DESC")
                          .where(filename: support_file["name"]).first&.md5

      support_file.merge("latest_etag" => latest_etag)
    end

    downloaded_support_files = Concurrent::Array.new

    threads = support_files.collect do |support_file|
      Thread.new do
        puts "Requesting #{support_file['name']}."

        file = Tempfile.new(support_file["name"])
        file.binmode

        request = HTTPI::Request.new(url: support_file["url"], open_timeout: 15)
        request.headers["If-None-Match"] = support_file["latest_etag"]

        request.on_body do |body|
          body.each_byte { |byte| file.print byte.chr }
        end

        response = HTTPI.get(request)
        puts "Request for #{support_file['name']} completed."
        file.flush

        downloaded_support_files.push(support_file.merge("file" => file, "response" => response))
      end
    end

    threads.each(&:join)

    downloaded_support_files.each do |support_file|
      if support_file["response"].code == 200
        puts "Uploading #{support_file['name']}."
        Uploads::Builder.new(
          support_file["file"].path, filename: support_file["name"], support_file: true, protected: true
        ).call
      elsif support_file["response"].code == 304
        puts "Latest version of #{support_file['name']} already exists. Skipping upload."
      else
        puts "Unable to download #{support_file['name']}. HTTP status: #{support_file['response'].code}"
      end

      support_file["file"].close!
    end

    puts "Total support files on staging: #{all_files_json['support_files'].size}"
    puts "Total support on dev #{Upload.support_files.count}"
  end
end
