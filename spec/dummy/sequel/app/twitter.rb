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
  config.client_class_name = 'Application'
  config.access_token_class_name = 'AccessToken'
  config.resource_owner_class_name = 'User'
  config.access_grant_class_name = 'AccessCode'

  config.realm = 'Custom Realm'

  config.allowed_grant_types << 'refresh_token'
end

# Models
require_relative 'models/application_record'
require_relative 'models/access_token'
require_relative 'models/access_code'
require_relative 'models/application'
require_relative 'models/user'

# Twitter Endpoints
require_relative 'resources/custom_token'
require_relative 'resources/custom_authorization'
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
    mount Twitter::Resources::CustomToken
    mount Twitter::Resources::CustomAuthorization
  end
end
