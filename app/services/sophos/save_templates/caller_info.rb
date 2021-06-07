# :nodoc
module Sophos
  # :nodoc
  module SaveTemplates
    # :nodoc
    class CallerInfo
      def initialize(credential, data = {})
        @credential = credential
        @data       = data
      end

      def call
        return if @data.blank? || @data["id"].blank? || @data["idType"].blank?

        params = { "#{@data['idType']}_id" => @data["id"] }.symbolize_keys
        @credential.update(params)
      end
    end
  end
end
