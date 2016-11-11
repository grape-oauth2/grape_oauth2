require 'grape'

require File.expand_path('../../../../../lib/grape_oauth2', __FILE__)

# SQLite memory database
DB = if defined?(JRUBY_VERSION)
       Sequel.connect('jdbc:sqlite::memory:')
     else
       Sequel.sqlite
     end

# Database
load File.expand_path('../config/db.rb', __FILE__)

GrapeOAuth2.configure do |config|
  config.client_class = 'Application'
  config.access_token_class = 'AccessToken'
  config.resource_owner_class = 'User'

  config.realm = 'Custom Realm'

  config.allowed_grant_types << 'refresh_token'
end

# Models
require_relative 'models/application_record'
require_relative 'models/access_token'
require_relative 'models/access_grant'
require_relative 'models/application'
require_relative 'models/user'

# Twitter Endpoints
require_relative 'resources/status'

module Twitter
  class API < Grape::API
    version 'v1', using: :path
    format :json
    prefix :api

    use *GrapeOAuth2.middleware

    helpers GrapeOAuth2::Helpers::AccessTokenHelpers

    mount GrapeOAuth2::Endpoints::Token
    mount GrapeOAuth2::Endpoints::Authorize

    mount Twitter::Resources::Status
  end
end
