module GrapeOAuth2
  class Configuration
    Error = Class.new(StandardError)

    include Validation

    DEFAULT_TOKEN_LIFETIME = 7200 # in seconds
    DEFAULT_CODE_LIFETIME = 7200

    DEFAULT_REALM = 'OAuth 2.0'.freeze

    SUPPORTED_GRANT_TYPES = %w(password client_credentials refresh_token).freeze

    attr_accessor :access_token_class_name, :access_grant_class_name,
                  :client_class_name, :resource_owner_class_name

    attr_accessor :scopes_validator_class_name

    attr_accessor :allowed_grant_types, :code_lifetime, :token_lifetime,
                  :issue_refresh_token, :revoke_after_refresh, :realm

    attr_accessor :token_authenticator

    def initialize
      initialize_classes
      initialize_authenticators

      self.token_lifetime = DEFAULT_TOKEN_LIFETIME
      self.code_lifetime = DEFAULT_CODE_LIFETIME
      self.allowed_grant_types = %w(password client_credentials)

      self.issue_refresh_token = false
      self.revoke_after_refresh = false

      self.realm = DEFAULT_REALM
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

    def access_token_class
      @_access_token_class ||= access_token_class_name.constantize
    end

    def resource_owner_class
      @_resource_owner_class ||= resource_owner_class_name.constantize
    end

    def client_class
      @_client_class ||= client_class_name.constantize
    end

    def access_grant_class
      @_access_grant_class ||= access_grant_class_name.constantize
    end

    def scopes_validator
      @_scopes_validator ||= scopes_validator_class_name.constantize
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
