# :nodoc
module MsGraph
  # :nodoc
  module SaveTemplates
    # :nodoc
    class SecureScoreProfile
      def initialize(app_id, cred_id, customer, events)
        @app_id = app_id
        @cred_id = cred_id
        @customer = customer
        @events = events
      end

      def call
        return if @events.blank?

        existing_records = RefSecureScore.where(scored: true, deprecated: false).pluck(:id).to_a

        @events.each do |event|
          next if existing_records.include?(event["id"])

          unless !event["title"].nil? && event["title"].include?("Not Scored")
            RefSecureScore.new(id: event["id"], scored: true, deprecated: false,
              max_score: event["maxScore"], details: event).save
          end
        end
      end
    end
  end
end
