module GrapeOAuth2
  class Configuration
    DEFAULT_CLIENT_CLASS = 'Application'.freeze
    DEFAULT_ACCESS_TOKEN_CLASS = 'AccessToken'.freeze
    DEFAULT_RESOURCE_OWNER_CLASS = 'User'.freeze

    DEFAULT_ALLOWED_GRANT_TYPES = %w(password).freeze
    DEFAULT_REFRESH_TOKEN = false
    DEFAULT_TOKEN_LIFETIME = 2.hours

    attr_accessor :client_class, :access_token_class, :resource_owner_class,
                  :allowed_grant_types, :token_lifetime, :refresh_token

    def initialize
      self.token_lifetime = DEFAULT_TOKEN_LIFETIME
      self.client_class = setup_class(DEFAULT_CLIENT_CLASS)
      self.access_token_class = setup_class(DEFAULT_ACCESS_TOKEN_CLASS)
      self.resource_owner_class = setup_class(DEFAULT_RESOURCE_OWNER_CLASS)
      self.allowed_grant_types = DEFAULT_ALLOWED_GRANT_TYPES
      self.refresh_token = DEFAULT_REFRESH_TOKEN
    end

    private

    def setup_class(klass)
      klass.is_a?(Class) ? klass : klass.constantize
    rescue NameError
      nil
    end
  end
end
