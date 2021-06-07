require "panic"

module Api
  module V1
    # Handle panic posts
    class PanicsController < ActionController::Base
      def create
        if valid_signature?
          relation.create(device_id: params[:id], contents: contents, expires_in: 1.month)
          head :created
        else
          head :ok
        end
      end

      private

      def valid_signature?
        signature == request.headers["X-Signature"]
      end

      def contents
        JSON.parse(request.body.tap(&:rewind).read)
      rescue JSON::ParserError
        request.body.tap(&:rewind).read
      end

      def signature
        digest = OpenSSL::Digest.new("sha256")
        OpenSSL::HMAC.hexdigest(digest, ENV.fetch("PANIC_SECRET", "secret"), request.body.tap(&:rewind).read)
      end

      def relation
        @relation ||= PanicRelation.new(OpenStruct.new(id: "panic"))
      end
    end
  end
end
