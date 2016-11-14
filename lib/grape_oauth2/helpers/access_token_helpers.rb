module GrapeOAuth2
  module Helpers
    module AccessTokenHelpers
      extend ::Grape::API::Helpers

      def access_token_required!(*scopes)
        endpoint_scopes = env['api.endpoint'].options[:route_options][:scopes]
        required_scopes = endpoint_scopes.presence || scopes

        raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized if current_access_token.nil?
        raise Rack::OAuth2::Server::Resource::Bearer::Forbidden unless valid_access_token?(required_scopes)
      end

      def current_resource_owner
        @_current_resource_owner ||= current_access_token.resource_owner
      end

      def current_access_token
        @_current_access_token ||= request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
      end

      private

      def valid_access_token?(scopes)
        !current_access_token.revoked? && !current_access_token.expired? &&
          GrapeOAuth2.config.scopes_validator_class.new(scopes).valid_for?(current_access_token)
      end
    end
  end
end
