module Api
  module V1
    PaymentRequiredError = Class.new(StandardError)

    # Base controller for all V1 API calls
    class BaseController < ActionController::Base
      SUPPORTED_FORMATS = %w[JSON].freeze

      rescue_from ActionController::UnknownFormat, ActionView::MissingTemplate, with: :format_not_supported
      rescue_from PaymentRequiredError, with: :payment_required
      helper_method :policy

      before_action :set_locale
      before_action :sample_transactions_for_scout_apm

      def append_info_to_payload(payload)
        super
        payload[:account] = @customer if @customer.present?
        # TODO: parse device in lograge custom attributes (app/lib/logging/...)
        payload[:device] = @device if @device.present?
      end

      private

      def remote_ip
        request.env["HTTP_X_FORWARDED_FOR"]&.split(",")&.first || request.remote_ip || "0.0.0.0"
      end

      def format_not_supported
        render plain: <<~TEXT
          Format not supported. Ensure request has content-type of one of the following:
          #{SUPPORTED_FORMATS.join(', ')}
        TEXT
      end

      def payment_required
        head :payment_required
      end

      def set_locale
        I18n.locale = extract_locale || I18n.default_locale
      end

      def extract_locale
        locale = request.host.split(".").second
        I18n.available_locales.map(&:to_s).include?(locale) ? locale : nil
      end

      def apm_sample_rate
        # sample at 1 percent
        0.01
      end

      def sample_transactions_for_scout_apm
        ScoutApm::Transaction.ignore! if rand > apm_sample_rate
      end
    end
  end
end
