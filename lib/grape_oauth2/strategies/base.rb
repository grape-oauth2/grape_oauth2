module GrapeOAuth2
  module Strategies
    class Base
      class << self
        def authenticate_client(request)
          config.client_class.authenticate(request.client_id, request.try(:client_secret))
        end

        def authenticate_resource_owner(client, request)
          config.resource_owner_class.oauth_authenticate(client, request.username, request.password)
        end

        def config
          GrapeOAuth2.config
        end

        def scopes_from(request)
          return nil if request.scope.nil?

          Array(request.scope).join(' ')
        end

        def expose_to_bearer_token(token)
          Rack::OAuth2::AccessToken::Bearer.new(token.to_bearer_token)
        end
      end
    end
  end
end
