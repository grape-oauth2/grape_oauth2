require 'active_record'
require 'grape'

require File.expand_path('../../../../lib/grape_oauth2', __FILE__)

# Database
load File.expand_path('../config/db.rb', __FILE__)

# Models
require_relative 'models/application_record'
require_relative 'models/access_token'
require_relative 'models/access_grant'
require_relative 'models/application'
require_relative 'models/user'

# Twitter Endpoints
require_relative 'resources/status'

GrapeOAuth2.configure do |config|
  config.client_class = Application
  config.access_token_class = AccessToken
  config.resource_owner_class = User
end

module Twitter
  class API < Grape::API
    version 'v1', using: :path
    format :json
    prefix :api

    use Rack::OAuth2::Server::Resource::Bearer, 'OAuth2 API' do |request|
      AccessToken.authenticate(request.access_token) || request.invalid_token!
    end

    helpers GrapeOAuth2::Helpers::AccessTokenHelpers

    mount GrapeOAuth2::Endpoints::Token
    mount GrapeOAuth2::Endpoints::Authorize

    mount Twitter::Resources::Status
  end
end
