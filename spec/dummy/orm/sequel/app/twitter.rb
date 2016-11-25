require 'grape'

require File.expand_path('../../../../../../lib/grape_oauth2', __FILE__)

# SQLite memory database
DB = if defined?(JRUBY_VERSION)
       Sequel.connect('jdbc:sqlite::memory:')
     else
       Sequel.sqlite
     end

# Database
load File.expand_path('../config/db.rb', __FILE__)

# Grape::OAuth2 config
load File.expand_path('../../../../grape_oauth2_config.rb', __FILE__)

# Models
require_relative 'models/application_record'
require_relative 'models/access_token'
require_relative 'models/access_code'
require_relative 'models/application'
require_relative 'models/user'

# Twitter Endpoints
require_relative '../../../endpoints/custom_token'
require_relative '../../../endpoints/custom_authorization'
require_relative '../../../endpoints/status'

module Twitter
  class API < Grape::API
    version 'v1', using: :path
    format :json
    prefix :api

    use *Grape::OAuth2.middleware

    helpers Grape::OAuth2::Helpers::AccessTokenHelpers

    mount Grape::OAuth2::Endpoints::Token
    mount Grape::OAuth2::Endpoints::Authorize

    mount Twitter::Endpoints::Status
    mount Twitter::Endpoints::CustomToken
    mount Twitter::Endpoints::CustomAuthorization
  end
end
