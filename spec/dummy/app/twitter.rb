require 'active_record'
require 'grape'

require File.expand_path('../../../../lib/grape_oauth2', __FILE__)

::ActiveRecord::Base.default_timezone = :utc

::ActiveRecord::Migration.verbose = false
::ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

load File.expand_path('../../db/schema.rb', __FILE__)

::ActiveRecord::Base.logger = Logger.new(STDOUT) unless ENV['RAILS_ENV'] == 'test'

# Models
require_relative 'models/application_record'
require_relative 'models/access_token'
require_relative 'models/application'
require_relative 'models/user'

# Endpoints
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

    helpers GrapeOAuth2::Helpers::AccessTokenHelpers

    mount Twitter::Resources::Status
    mount GrapeOAuth2::Endpoint
  end
end
