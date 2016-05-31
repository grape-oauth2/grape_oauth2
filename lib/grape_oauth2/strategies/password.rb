module GrapeOAuth2
  module Strategies
    class Password
      class << self
        def process(client, request, &_authenticator)
          resource_owner = if block_given?
                             yield client, request
                           else
                             authenticate_resource_owner!(client, request)
                           end

          request.invalid_grant! unless resource_owner

          token = GrapeOAuth2.config.access_token_class.create_for(client, resource_owner)
          token.to_bearer_token
        end

        def authenticate_resource_owner!(client, request)
          resource_owner = GrapeOAuth2.config.resource_owner_class
          resource_owner.oauth_authenticate(client, request.username, request.password)
        end
      end
    end
  end
end
