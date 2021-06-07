module Api
  module V1
    module Devices
      # Submit a device crash reports
      class CrashReportsController < Api::V1::Devices::DevicesBaseController
        def create
          crash_report = device.crash_reports.new(
            upload_id: params[:upload_id]
          )

          if crash_report.save
            head :created
          else
            head :bad_request
          end
        end
      end
    end
  end
end
