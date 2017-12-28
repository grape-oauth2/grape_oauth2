module Grape
  module OAuth2
    module Helpers
      # Set of Grape OAuth2 helpers.
      module AccessTokenHelpers
        extend ::Grape::API::Helpers

        # Adds OAuth2 Access Token protection for Grape routes.
        #
        # @param scopes [Array]
        #   set of scopes required to access the endpoint
        #
        # @raise [Rack::OAuth2::Server::Resource::Bearer::Unauthorized]
        #   invalid Access Token value
        # @raise [Rack::OAuth2::Server::Resource::Bearer::Forbidden]
        #   Access Token expired, revoked or does't have required scopes
        #
        def access_token_required!(*scopes)
          endpoint_scopes = env['api.endpoint'].options[:route_options][:scopes]
          required_scopes = endpoint_scopes.presence || scopes

          raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized if current_access_token.nil?
          raise Rack::OAuth2::Server::Resource::Bearer::Forbidden unless valid_access_token?(required_scopes)
        end

        # Returns Resource Owner from the Access Token
        # found by access_token value passed with the request.
        def current_resource_owner
          @_current_resource_owner ||= current_access_token.resource_owner
        end

        # Returns Access Token instance found by
        # access_token value passed with the request.
        def current_access_token
          @_current_access_token ||= request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
        end

        # Validate current access token not to be expired or revoked
        # and has all the requested scopes.
        #
        # @return [Boolean]
        #   true if current Access Token not expired, not revoked and scopes match
        #   false in other cases.
        #
        def valid_access_token?(scopes)
          !current_access_token.revoked? && !current_access_token.expired? &&
            Grape::OAuth2.config.scopes_validator.new(scopes).valid_for?(current_access_token)
        end
      end
    end
  end
end
