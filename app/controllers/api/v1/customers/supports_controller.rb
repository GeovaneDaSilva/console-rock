module Api
  module V1
    module Customers
      # Account devices
      class SupportsController < Api::V1::Customers::CustomersBaseController
        def index
          @support_files = upload_scope
          render "api/v1/supports/index"
        end

        def show
          upload = upload_scope.where(filename: filename).first!

          redirect_to upload.url
        end

        private

        def upload_scope
          if @customer.agent_release_id.present?
            @customer.agent_release.uploads
          else
            Upload.support_files.protected_files
                  .reorder("created_at DESC")
          end
        end

        def filename
          @filename ||= request.url.split("/").last
        end

        def skip_payment_required?
          filename.match(/\.(exe|dll|bin)$/)
        end
      end
    end
  end
end
