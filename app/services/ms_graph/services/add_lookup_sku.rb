# :nodoc
module MsGraph
  # :nodoc
  module Services
    # :nodoc
    class AddLookupSku
      def initialize(cred, sku_id, url = nil)
        @cred = cred
        @sku_id = sku_id
        @url = url || "https://graph.microsoft.com/v1.0/subscribedSkus"
      end

      def call
        return if @sku_id.nil?
        return if LookupSkus.where(id: @sku_id).present?

        new_record = make_api_call
        return if new_record.blank?

        new_record["value"].each do |one|
          if one.dig("skuId") == @sku_id
            LookupSkus.new(id: one["skuId"], name: one["skuPartNumber"]).save
            return nil
          end
        end

        if new_record.include?("@odata.nextLink")
          ServiceRunnerJob.perform_later(
            "MsGraph::Services::AddLookupSku", @cred, @sku_id, new_record["@odata.nextLink"]
          )
        end
      rescue ActiveRecord::RecordNotUnique
        nil # this is just to avoid the rubocop whine about suppressing exceptions.
        # could also put a lock while these are happening, but a RecordNotUnique exception just
        # prevents the new record (which is the desired behavior anyway)
      end

      private

      def make_api_call
        token = MsGraph::CredentialUpdater.new.call(@cred)
        headers = {
          Authorization: "Bearer #{token}"
        }

        request = HTTPI::Request.new
        request.url = @url
        request.headers = headers

        begin
          resp = HTTPI.get(request)
        rescue Errno::ECONNRESET
          raise MsGraph::ConnectionPeerResetError
        end

        unless resp.code == 200
          Rails.logger.error(
            "MS Graph Lookup SKU Template API failure code #{resp.code} with message"\
            " #{JSON.parse(resp.raw_body)}"
          )
          return []
        end

        JSON.parse(resp.raw_body) || []
      end
    end
  end
end
