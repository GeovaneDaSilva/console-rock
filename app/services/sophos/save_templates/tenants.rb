# :nodoc
module Sophos
  # :nodoc
  module SaveTemplates
    # :nodoc
    class Tenants
      def initialize(credential, data_json)
        @credential = credential
        @data_json  = data_json
      end

      def call
        return if @data_json.blank?

        items = JSON.parse(@data_json)
        tenants = items.map do |item|
          [item["id"], { "apiHost" => item["apiHost"], "name" => item["name"] }]
        end.to_h

        @credential.update(tenants: tenants)
      end
    end
  end
end
