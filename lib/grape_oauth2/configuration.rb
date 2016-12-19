module Grape
  module OAuth2
    # Grape::OAuth2 configuration class.
    # Contains default or customized options that would be used
    # in OAuth2 endpoints and helpers.
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

      # Currently supported (by the gem) OAuth2 grant types
      SUPPORTED_GRANT_TYPES = %w(password client_credentials refresh_token).freeze

      # The names of the classes that represents OAuth2 roles
      #
      # @return [String] class name
      #
      attr_accessor :access_token_class_name, :access_grant_class_name,
                    :client_class_name, :resource_owner_class_name

      # Class name for the OAuth2 helper class that validates requested scopes against Access Token scopes
      #
      # @return [String] scopes validator class name
      #
      attr_accessor :scopes_validator_class_name

      # Class name for the OAuth2 helper class that generates unique token values
      #
      # @return [String] token generator class name
      #
      attr_accessor :token_generator_class_name

      #  OAuth2 grant types (flows) allowed to be processed
      #
      # @return [Array<String>] grant types
      #
      attr_accessor :allowed_grant_types

      # Access Token and Authorization Code lifetime in seconds
      attr_accessor :authorization_code_lifetime, :access_token_lifetime

      # Specifies whether to generate a Refresh Token when creating an Access Token
      #
      # @return [Boolean] true if need to generate refresh token, false in other case
      #
      attr_accessor :issue_refresh_token

      # Realm value
      #
      # @return [String] realm
      #
      attr_accessor :realm

      # Access Token authenticator block option for customization
      attr_accessor :token_authenticator

      # Callback that would be invoked during processing of Refresh Token request for
      # the original Access Token found by token value
      attr_accessor :on_refresh

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
