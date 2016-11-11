module GrapeOAuth2
  class Configuration
    DEFAULT_CLIENT_CLASS = '::Application'.freeze
    DEFAULT_ACCESS_TOKEN_CLASS = '::AccessToken'.freeze
    DEFAULT_ACCESS_GRANT_CLASS = '::AccessGrant'.freeze
    DEFAULT_RESOURCE_OWNER_CLASS = '::User'.freeze

    DEFAULT_TOKEN_LIFETIME = 7200 # in seconds
    DEFAULT_CODE_LIFETIME = 7200

    DEFAULT_REALM = 'OAuth 2.0'.freeze

    SUPPORTED_GRANT_TYPES = %w(password client_credentials refresh_token).freeze

    attr_accessor :client_class, :access_token_class, :resource_owner_class,
                  :access_grant_class

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

    # Checks configuration to be set correctly (requires classes
    # must exist and respond to the specific set of API methods).
    def check!
      check_required_classes!
      check_required_classes_api!
    end

    private

    REQUIRED_CLASSES_API = {
      access_token_class: {
        class_methods: %i(authenticate create_for),
        instance_methods: %i(expired? revoked? revoke! to_bearer_token)
      },
      client_class: {
        class_methods: %i(authenticate)
      },
      resource_owner_class: {
        class_methods: %i(oauth_authenticate)
      }
    }.freeze

    def initialize_classes
      self.client_class = DEFAULT_CLIENT_CLASS
      self.access_token_class = DEFAULT_ACCESS_TOKEN_CLASS
      self.resource_owner_class = DEFAULT_RESOURCE_OWNER_CLASS
      self.access_grant_class = DEFAULT_ACCESS_GRANT_CLASS
    end

    def initialize_authenticators
      self.token_authenticator = default_token_authenticator
    end

    def check_required_classes!
      [:access_token_class, :client_class, :resource_owner_class].each do |klass|
        raise "#{klass} must be defined!" unless defined?(send(klass))
      end
    end

    def check_required_classes_api!
      REQUIRED_CLASSES_API.each do |klass, api_methods|
        api_methods[:class_methods].each do |method|
          raise "Class method '#{method}' must be defined for the '#{klass}'!" unless send(klass).respond_to?(method)
        end

        (api_methods[:instance_methods] || []).each do |method|
          unless send(klass).method_defined?(method)
            raise "Instance method '#{method}' must be defined for the '#{klass}'!"
          end
        end
      end
    end
  end
end
