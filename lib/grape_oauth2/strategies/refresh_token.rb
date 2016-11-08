module GrapeOAuth2
  module Strategies
    class RefreshToken < Base
      class << self
        def process(request, &authenticator)
          client = authenticate_client(request, &authenticator)

          request.invalid_client! if client.nil?

          refresh_token = config.access_token_class.authenticate(request.refresh_token, type: :refresh_token)
          request.invalid_grant! if refresh_token.nil?
          request.unauthorized_client! if refresh_token && refresh_token.client != client

          token = config.access_token_class.create_for(client, refresh_token.resource_owner)
          refresh_token.revoke! if config.revoke_after_refresh

          token.to_bearer_token
        end
      end
    end
  end
end
