require 'grape'
require 'rack/oauth2'

require 'grape_oauth2/version'
require 'grape_oauth2/configuration/validation'
require 'grape_oauth2/configuration/class_accessors'
require 'grape_oauth2/configuration'
require 'grape_oauth2/scopes'
require 'grape_oauth2/unique_token'

# NOTE: Extract to separate gems!!!
# This gem should contains only the core functionality and all mixins
# need to be moved to their own repos with their own tests.
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

# Authorization Grants aka Flows (Strategies)
require 'grape_oauth2/strategies/base'
require 'grape_oauth2/strategies/authorization_code'
require 'grape_oauth2/strategies/password'
require 'grape_oauth2/strategies/client_credentials'
require 'grape_oauth2/strategies/refresh_token'

# Generators
require 'grape_oauth2/generators/base'
require 'grape_oauth2/generators/token'
require 'grape_oauth2/generators/authorization'

# Grape Helpers
require 'grape_oauth2/helpers/access_token_helpers'
require 'grape_oauth2/helpers/oauth_params'

# Responses
require 'grape_oauth2/responses/base'
require 'grape_oauth2/responses/authorization'
require 'grape_oauth2/responses/token'

# Grape Endpoints
require 'grape_oauth2/endpoints/token'
require 'grape_oauth2/endpoints/authorize'

# Use Grape namespace for the gem.
module Grape
  # Main Grape::OAuth2 module.
  module OAuth2
    class << self
      # Grape::OAuth2 configuration.
      #
      # @return [Grape::OAuth2::Configuration]
      #   configuration object
      #
      def config
        @config ||= Grape::OAuth2::Configuration.new
      end

      # Configures Grape::OAuth2.
      # Yields Grape::OAuth2::Configuration instance to the block.
      def configure
        yield config
      end

      # Validates Grape::OAuth2 configuration to be set correctly.
      def check_configuration!
        config.check!
      end

      # Grape::OAuth2 default middleware.
      def middleware
        [Rack::OAuth2::Server::Resource::Bearer, config.realm, config.token_authenticator]
      end

      # Method for injecting Grape::OAuth2 endpoints and helpers
      # into Grape API class. Automatically set required middleware,
      # OAuth2 helpers and mounts all (or configured) endpoints.
      #
      # @param endpoints [Array<Symbol>, Array<String>] endpoints to add
      #
      def api(*endpoints)
        inject_to_api do |api|
          api.use(*Grape::OAuth2.middleware)
          api.helpers(Grape::OAuth2::Helpers::AccessTokenHelpers)

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
          token: ::Grape::OAuth2::Endpoints::Token,
          authorize: ::Grape::OAuth2::Endpoints::Authorize
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
end
