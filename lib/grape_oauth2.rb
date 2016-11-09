require 'grape'
require 'rack/oauth2'

require 'grape_oauth2/version'
require 'grape_oauth2/configuration'
require 'grape_oauth2/scopes'

# Extract to separate gems
# Mixins
if defined?(ActiveRecord::Base)
  require 'grape_oauth2/mixins/active_record/access_token'
  require 'grape_oauth2/mixins/active_record/access_grant'
  require 'grape_oauth2/mixins/active_record/client'
elsif defined?(Sequel)
  require 'grape_oauth2/mixins/sequel/access_token'
  require 'grape_oauth2/mixins/sequel/access_grant'
  require 'grape_oauth2/mixins/sequel/client'
end

# Authorization Grants (Strategies)
require 'grape_oauth2/strategies/base'
require 'grape_oauth2/strategies/password'
require 'grape_oauth2/strategies/client_credentials'
require 'grape_oauth2/strategies/refresh_token'

# Generators
require 'grape_oauth2/generators/base'
require 'grape_oauth2/generators/token'
require 'grape_oauth2/generators/authorization_code'

# Helpers
require 'grape_oauth2/helpers/access_token_helpers'
require 'grape_oauth2/helpers/oauth_params'

# Responses
require 'grape_oauth2/responses/token_response'

# Endpoints
require 'grape_oauth2/endpoints/token'
require 'grape_oauth2/endpoints/authorize'

module GrapeOAuth2
  def self.config
    @config ||= GrapeOAuth2::Configuration.new
  end

  def self.configure
    yield config
  end

  def self.middleware
    return Rack::OAuth2::Server::Resource::Bearer, config.realm, lambda do |request|
      config.access_token_class.authenticate(request.access_token) || request.invalid_token!
    end
  end
end
