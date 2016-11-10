require 'otr-activerecord'
require 'grape'

require File.expand_path('../../../../../lib/grape_oauth2', __FILE__)

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

  config.realm = 'Custom Realm'

  config.allowed_grant_types << 'refresh_token'
end

module Twitter
  class API < Grape::API
    version 'v1', using: :path
    format :json
    prefix :api

    include GrapeOAuth2.api

    mount Twitter::Resources::Status
  end
end
