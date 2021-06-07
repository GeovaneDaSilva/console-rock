module Logging
  # extracts additional payload attributes from the current context and appends them
  # to logs
  #
  # Accepts type to flatten log output or to leave as nested objects
  class LogrageCustomOptions
    LogrageCustomOptionsError = Class.new(StandardError)

    class << self
      def call(*args)
        new(*args).call
      end
    end

    def initialize(event, output = :nested)
      @event = event
      @output = output
      @attributes = {}
    end

    attr_reader :attributes, :event
    delegate :payload, to: :event

    def call
      attributes[:time] = Time.now.iso8601
      attributes[:host] = ENV["HOST"]
      attributes[:pid] = $PROCESS_ID
      attributes[:request_id] = payload[:request].request_id if payload[:request].present?

      append(controller_params) if payload[:params].present?
      append(user_attributes) if payload[:user].present?
      append(provider_attributes) if payload[:provider].present?
      append(account_attributes) if payload[:account].present?

      self
    rescue StandardError => e
      error = LogrageCustomOptionsError.new("Could not extract logging payload from event")
      output = error.as_json.merge({ cause: e.as_json })
      @attributes = { logging_error: output }.deep_symbolize_keys
      self
    end

    def controller_params
      params = payload[:params]
      AttributesBuilder.build(:params, params) do |builder|
        builder.reject "controller", "action"
      end
    end

    def user_attributes
      user = payload[:user]
      AttributesBuilder.build(:current_user, user) do |builder|
        builder.extract :id, :email, :admin?, :admin_role
        builder.reassign :admin?, :is_admin
      end
    end

    def provider_attributes
      provider = payload[:provider]
      AttributesBuilder.build(:current_provider, provider) do |builder|
        builder.extract :id, :name, :paid_thru, :marked_for_deletion, :type
      end
    end

    def account_attributes
      account = payload[:account]
      AttributesBuilder.build(:current_account, account) do |builder|
        builder.extract :id, :name, :path, :type
      end
    end

    private

    def append(attrs)
      @attributes.merge!(attrs)
    end

    # simple class used to create a friendly DSL for extracting values from models
    class AttributesBuilder
      class << self
        def build(key, struct, output = :nested)
          builder = yield new(key, struct, output)
          case output
          when :nested then { key => builder.attributes }
          else
            builder.attributes
          end
        end
      end

      def initialize(key, struct, output)
        @key = key
        @output = output
        @struct = struct
        @attributes = {}
      end

      attr_accessor :attributes, :struct, :key, :output

      def extract(*symbols)
        symbols.each do |symbol|
          case output
          when :nested
            @attributes[symbol] = struct.send(symbol.to_sym) if struct.respond_to?(symbol.to_sym)
          else
            @attributes[object_key(symbol)] = struct.send(symbol.to_sym) if struct.respond_to?(symbol.to_sym)
          end
        end

        self
      end

      def reassign(key, new_key)
        @attributes[new_key] = @attributes.delete(key)
        self
      end

      def reject(*keys)
        # only set struct to attributes if no other operations on attributes have occurred,
        # otherwise reject directly on the hash
        @attributes = struct if attributes.blank?
        @attributes = attributes.reject { |key| keys.include?(key) }

        self
      end

      private

      def object_key(symbol)
        "#{key}_#{symbol}"
      end
    end
  end
end
