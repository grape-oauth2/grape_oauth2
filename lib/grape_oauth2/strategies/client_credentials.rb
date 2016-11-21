module GrapeOAuth2
  module Strategies
    class ClientCredentials < Base
      class << self
        def process(request, &authenticator)
          client = authenticate_client(request, &authenticator)

          request.invalid_client! if client.nil?

          token = config.access_token_class.create_for(client, nil, scopes_from(request))
          expose_to_bearer_token(token)
        end
      end
    end
  end
end
