require 'otr-activerecord'
require 'grape'

require File.expand_path('../../../../../../lib/grape_oauth2', __FILE__)

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

    include Grape::OAuth2.api

    mount Twitter::Endpoints::Status
    mount Twitter::Endpoints::CustomToken
    mount Twitter::Endpoints::CustomAuthorization
  end
end
