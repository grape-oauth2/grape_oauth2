module Grape
  module OAuth2
    module Strategies
      # Client Credentials strategy class.
      # Processes request and respond with Access Token.
      class ClientCredentials < Base
        class << self
          # Processes Client Credentials request.
          def process(request)
            client = authenticate_client(request)
            request.invalid_client! if client.nil?

            token = config.access_token_class.create_for(client, nil, scopes_from(request))
            expose_to_bearer_token(token)
          end
        end
      end
    end
  end
end
