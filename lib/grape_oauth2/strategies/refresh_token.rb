module GrapeOAuth2
  module Strategies
    class RefreshToken < Base
      class << self
        def process(request, &authenticator)
          client = authenticate_client!(request, &authenticator)

          request.invalid_client! if client.nil?

          refresh_token = client.refresh_tokens.active.by_refresh_token(request.refresh_token)
          request.invalid_grant! if refresh_token.nil?

          token = GrapeOAuth2.config.access_token_class.create_for(client, refresh_token.resource_owner)
          token.to_bearer_token
        end
      end
    end
  end
end
