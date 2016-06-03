module GrapeOAuth2
  class Configuration
    DEFAULT_CLIENT_CLASS = '::Application'.freeze
    DEFAULT_ACCESS_TOKEN_CLASS = '::AccessToken'.freeze
    DEFAULT_RESOURCE_OWNER_CLASS = '::User'.freeze

    DEFAULT_ALLOWED_GRANT_TYPES = %w(password client_credentials).freeze
    DEFAULT_REFRESH_TOKEN = false
    DEFAULT_TOKEN_LIFETIME = 7200 # in seconds

    attr_accessor :client_class, :access_token_class, :resource_owner_class,
                  :allowed_grant_types, :token_lifetime, :refresh_token

    def initialize
      self.client_class = DEFAULT_CLIENT_CLASS
      self.access_token_class = DEFAULT_ACCESS_TOKEN_CLASS
      self.resource_owner_class = DEFAULT_RESOURCE_OWNER_CLASS

      self.token_lifetime = DEFAULT_TOKEN_LIFETIME
      self.allowed_grant_types = DEFAULT_ALLOWED_GRANT_TYPES
      self.refresh_token = DEFAULT_REFRESH_TOKEN
    end
  end
end
