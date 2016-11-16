require 'grape'
require 'rack/oauth2'

require 'grape_oauth2/version'
require 'grape_oauth2/configuration/validation'
require 'grape_oauth2/configuration'
require 'grape_oauth2/scopes'

# Extract to separate gems!!!
# Mixins
if defined?(ActiveRecord::Base)
  require 'grape_oauth2/mixins/active_record/access_token'
  require 'grape_oauth2/mixins/active_record/access_grant'
  require 'grape_oauth2/mixins/active_record/client'
elsif defined?(Sequel::Model)
  require 'grape_oauth2/mixins/sequel/access_token'
  require 'grape_oauth2/mixins/sequel/access_grant'
  require 'grape_oauth2/mixins/sequel/client'
elsif defined?(Mongoid::Document)
  require 'grape_oauth2/mixins/mongoid/access_token'
  require 'grape_oauth2/mixins/mongoid/access_grant'
  require 'grape_oauth2/mixins/mongoid/client'
end

# Authorization Grants (Strategies)
require 'grape_oauth2/strategies/base'
require 'grape_oauth2/strategies/authorization_code'
require 'grape_oauth2/strategies/password'
require 'grape_oauth2/strategies/client_credentials'
require 'grape_oauth2/strategies/refresh_token'

# Generators
require 'grape_oauth2/generators/base'
require 'grape_oauth2/generators/token'
require 'grape_oauth2/generators/authorization'

# Helpers
require 'grape_oauth2/helpers/access_token_helpers'
require 'grape_oauth2/helpers/oauth_params'

# Responses
require 'grape_oauth2/responses/base'
require 'grape_oauth2/responses/authorization_response'
require 'grape_oauth2/responses/token_response'

# Endpoints
require 'grape_oauth2/endpoints/token'
require 'grape_oauth2/endpoints/authorize'

module GrapeOAuth2
  class << self
    def config
      @config ||= GrapeOAuth2::Configuration.new
    end

    def configure
      yield config
    end

    def check_configuration!
      config.check!
    end

    def middleware
      [Rack::OAuth2::Server::Resource::Bearer, config.realm, config.token_authenticator]
    end

    def api(*endpoints)
      inject_to_api do |api|
        api.use(*GrapeOAuth2.middleware)
        api.helpers(GrapeOAuth2::Helpers::AccessTokenHelpers)

        (endpoints.presence || endpoints_mapping.keys).each do |name|
          endpoint = endpoints_mapping[name.to_sym]
          raise ArgumentError, "Unrecognized endpoint: #{endpoint}" if endpoint.nil?

          api.mount(endpoint)
        end
      end
    end

    private

    def endpoints_mapping
      {
        token: GrapeOAuth2::Endpoints::Token,
        authorize: GrapeOAuth2::Endpoints::Authorize
      }
    end

    def inject_to_api(&_block)
      raise ArgumentError, 'block must be specified!' unless block_given?

      Module.new do |mod|
        mod.define_singleton_method :included do |base|
          yield base
        end
      end
    end
  end
end
