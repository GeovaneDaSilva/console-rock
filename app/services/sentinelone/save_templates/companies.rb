# :nodoc
module Sentinelone
  # :nodoc
  module SaveTemplates
    # :nodoc
    class Companies
      def initialize(_app_id, cred, event)
        @cred   = cred
        @sites  = event.dig("sites").map { |b| [b["id"], b["name"]] }
      end

      def call
        return if @sites.blank?

        sites = @cred.sites || []
        sites |= @sites
        sites = sites.sort_by { |site| site[1].downcase }

        @cred.update(sites: sites)
      end
    end
  end
end
