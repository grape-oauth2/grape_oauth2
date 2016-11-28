module Grape
  module OAuth2
    class Configuration
      # Default Grape::OAuth2 configuration error class.
      Error = Class.new(StandardError)
      # Grape::OAuth2 configuration error for missing API required for OAuth2 classes.
      APIMissing = Class.new(Error)

      include Validation
      include ClassAccessors

      # Default Access Token TTL (in seconds)
      DEFAULT_TOKEN_LIFETIME = 7200
      # Default Authorization Code TTL ()in seconds)
      DEFAULT_CODE_LIFETIME = 1800

      # Default realm value
      DEFAULT_REALM = 'OAuth 2.0'.freeze

      # Currently supported (be the gem) OAuth2 grant types
      SUPPORTED_GRANT_TYPES = %w(password client_credentials refresh_token).freeze

      # @attr [String] class names for classes that represents OAuth2 roles
      attr_accessor :access_token_class_name, :access_grant_class_name,
                    :client_class_name, :resource_owner_class_name

      # @attr [String] class names for helper classes
      attr_accessor :scopes_validator_class_name, :token_generator_class_name

      attr_accessor :allowed_grant_types, :authorization_code_lifetime, :access_token_lifetime,
                    :issue_refresh_token, :realm

      attr_accessor :token_authenticator, :on_refresh

      def initialize
        reset!
      end

      # Default Access Token authenticator block.
      # Validates token value passed with the request params.
      def default_token_authenticator
        lambda do |request|
          access_token_class.authenticate(request.access_token) || request.invalid_token!
        end
      end

      # Accessor for Access Token authenticator block. Set it to proc
      # if called with block or returns current value of the accessor.
      def token_authenticator(&block)
        if block_given?
          instance_variable_set(:'@token_authenticator', block)
        else
          instance_variable_get(:'@token_authenticator')
        end
      end

      # Accessor for on_refresh callback. Set callback proc
      # if called with block or returns current value of the accessor.
      def on_refresh(&block)
        if block_given?
          instance_variable_set(:'@on_refresh', block)
        else
          instance_variable_get(:'@on_refresh')
        end
      end

      # Indicates if on_refresh callback can be invoked.
      #
      # @return [Boolean]
      #   true if callback can be invoked and false in other cases
      #
      def on_refresh_runnable?
        !on_refresh.nil? && on_refresh != :nothing
      end

      # Reset configuration to default options values.
      def reset!
        initialize_classes
        initialize_authenticators

        self.access_token_lifetime = DEFAULT_TOKEN_LIFETIME
        self.authorization_code_lifetime = DEFAULT_CODE_LIFETIME
        self.allowed_grant_types = %w(password client_credentials)

        self.issue_refresh_token = false
        self.on_refresh = :nothing

        self.realm = DEFAULT_REALM
      end

      private

      # Sets OAuth2 helpers classes to gem defaults.
      def initialize_classes
        self.scopes_validator_class_name = Grape::OAuth2::Scopes.name
        self.token_generator_class_name = Grape::OAuth2::UniqueToken.name
      end

      # Sets authenticators to gem defaults.
      def initialize_authenticators
        self.token_authenticator = default_token_authenticator
      end
    end
  end
end
