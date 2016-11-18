module GrapeOAuth2
  class Configuration
    Error = Class.new(StandardError)
    APIMissing = Class.new(Error)

    include Validation
    include ClassAccessors

    DEFAULT_TOKEN_LIFETIME = 7200 # in seconds
    DEFAULT_CODE_LIFETIME = 7200

    DEFAULT_REALM = 'OAuth 2.0'.freeze

    SUPPORTED_GRANT_TYPES = %w(password client_credentials refresh_token).freeze

    attr_accessor :access_token_class_name, :access_grant_class_name,
                  :client_class_name, :resource_owner_class_name

    attr_accessor :scopes_validator_class_name

    attr_accessor :allowed_grant_types, :code_lifetime, :token_lifetime,
                  :issue_refresh_token, :realm

    attr_accessor :token_authenticator, :on_refresh

    def initialize
      reset!
    end

    def default_token_authenticator
      lambda do |request|
        access_token_class.authenticate(request.access_token) || request.invalid_token!
      end
    end

    def token_authenticator(&block)
      if block_given?
        instance_variable_set(:'@token_authenticator', block)
      else
        instance_variable_get(:'@token_authenticator')
      end
    end

    def on_refresh(&block)
      if block_given?
        instance_variable_set(:'@on_refresh', block)
      else
        instance_variable_get(:'@on_refresh')
      end
    end

    def on_refresh?
      !on_refresh.nil? && on_refresh != :nothing
    end

    def reset!
      initialize_classes
      initialize_authenticators

      self.token_lifetime = DEFAULT_TOKEN_LIFETIME
      self.code_lifetime = DEFAULT_CODE_LIFETIME
      self.allowed_grant_types = %w(password client_credentials)

      self.issue_refresh_token = false
      self.on_refresh = :nothing

      self.realm = DEFAULT_REALM
    end

    private

    def initialize_classes
      self.scopes_validator_class_name = GrapeOAuth2::Scopes.name
    end

    def initialize_authenticators
      self.token_authenticator = default_token_authenticator
    end
  end
end
