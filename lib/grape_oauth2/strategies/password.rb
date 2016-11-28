module Grape
  module OAuth2
    module Strategies
      # Resource Owner Password Credentials strategy class.
      # Processes request and respond with Access Token.
      class Password < Base
        class << self
          def process(request)
            client = authenticate_client(request) || request.invalid_client!
            resource_owner = authenticate_resource_owner(client, request)

            request.invalid_grant! if resource_owner.nil?

            token = config.access_token_class.create_for(client, resource_owner, scopes_from(request))
            expose_to_bearer_token(token)
          end
        end
      end
    end
  end
end
