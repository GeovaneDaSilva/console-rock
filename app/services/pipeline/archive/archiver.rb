module Pipeline
  module Archive
    # nodoc
    class Archiver
      def initialize(customer_id)
        deletion_time_threshold = PIPELINE_CONFIGS.dig(:archive, :app_results_threshold).ago || 95.days.ago
        archive_limit = PIPELINE_CONFIGS.dig(:archive, :archive_limit) || 5000
        @customer = Customer.find(customer_id)
        all_results = @customer.all_descendant_app_results
                               .where("created_at < ?", deletion_time_threshold)
                               .where(archive_state: :active)
                               .order(:detection_date)
        @results = all_results.limit(archive_limit)
        @remaining_results_count = all_results.size - archive_limit
      rescue ActiveRecord::RecordNotFound
        @customer = nil
        Rails.logger.error("Failed to archive results for customer #{customer_id}")
      end

      # -- try to ennsure that if I "archive" 3 app results today, they don't get thrown in with these
      #
      # ...while at the same time, I don't necessarily want to have them hang around until
      # they would be auto-archived either...

      def call
        return if @customer.nil? || @results.blank?

        raise S3SaveError unless upload_records

        @results.update_all(archive_state: :archived)

        # ServiceRunnerJob.perform_later("Pipeline::Archive::Destroyer", "app_results", @customer.id)
        return unless @remaining_results_count > 2500

        ServiceRunnerJob.perform_later("Pipeline::Archive::Archiver", @customer.id)
      end

      private

      def upload_records
        start_time = @results.first.detection_date
        end_time = @results.last.detection_date
        filename = "#{@customer.id}FROM#{start_time.iso8601}TO#{end_time.iso8601}.gz"

        size = Zlib::GzipWriter.open(filename) do |gz|
          gz.write(@results.to_a.to_json)
        end

        create_upload!(filename, size) ? create_archive!(start_time, end_time) : false
      end

      def create_upload!(filename, size)
        @upload = @customer.uploads.create(filename: filename, size: size)
        if @upload.bucket.object(@upload.key).upload_file(filename, upload_options)
          File.delete(filename)
        else
          false
        end
      end

      def upload_options
        {
          acl:          "private",
          content_type: @upload.mime_type.to_s
        }
      end

      def create_archive!(start_time, end_time)
        ResultArchive.new(
          upload:     @upload,
          customer:   @customer,
          start_time: start_time,
          end_time:   end_time
        ).save
      end
    end
  end
end
