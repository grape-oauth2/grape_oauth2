module GrapeOAuth2
  class Configuration
    DEFAULT_CLIENT_CLASS = '::Application'.freeze
    DEFAULT_ACCESS_TOKEN_CLASS = '::AccessToken'.freeze
    DEFAULT_ACCESS_GRANT_CLASS = '::AccessGrant'.freeze
    DEFAULT_RESOURCE_OWNER_CLASS = '::User'.freeze

    DEFAULT_REFRESH_TOKEN = false
    DEFAULT_TOKEN_LIFETIME = 7200 # in seconds
    DEFAULT_GRANT_LIFETIME = 7200

    attr_accessor :client_class, :access_token_class, :resource_owner_class,
                  :access_grant_class

    attr_accessor :allowed_grant_types, :grant_lifetime, :token_lifetime,
                  :refresh_token

    def initialize
      self.client_class = DEFAULT_CLIENT_CLASS
      self.access_token_class = DEFAULT_ACCESS_TOKEN_CLASS
      self.resource_owner_class = DEFAULT_RESOURCE_OWNER_CLASS
      self.access_grant_class = DEFAULT_ACCESS_GRANT_CLASS

      self.allowed_grant_types = %w(password client_credentials)
      self.token_lifetime = DEFAULT_TOKEN_LIFETIME
      self.grant_lifetime = DEFAULT_GRANT_LIFETIME
      self.refresh_token = DEFAULT_REFRESH_TOKEN
    end
  end
end
