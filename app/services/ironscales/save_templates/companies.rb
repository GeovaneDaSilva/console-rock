# :nodoc
module Ironscales
  # :nodoc
  module SaveTemplates
    # Saves list of IronScales companies associated with credential
    class Companies
      def initialize(cred, companies, _company_id)
        @cred = cred.is_a?(Integer) ? Credentials::Ironscales.find(cred) : cred
        @companies = companies&.dig("companies")
      rescue ActiveRecord::RecordNotFound
        @cred = nil
      end

      def call
        return if @cred.nil? || @companies.blank?

        @cred.companies = [] if @cred.companies.nil?
        @cred.companies |= @companies
        return unless @cred.changed?

        @cred.companies = @cred.companies.sort_by { |h| h["name"] }
        @cred.save
      end
    end
  end
end
