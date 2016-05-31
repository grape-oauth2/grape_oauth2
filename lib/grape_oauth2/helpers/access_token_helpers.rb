module GrapeOAuth2
  module Helpers
    module AccessTokenHelpers
      extend ::Grape::API::Helpers

      def access_token_required!
        raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized unless current_access_token
      end

      def current_resource_owner
        @_current_resource_owner ||= current_access_token.resource_owner
      end

      def current_access_token
        @_current_access_token ||= request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
      end
    end
  end
end
