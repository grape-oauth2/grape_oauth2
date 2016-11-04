module GrapeOAuth2
  module Strategies
    class Password < Base
      class << self
        def process(request, &authenticator)
          client = authenticate_client(request) || request.invalid_client!
          resource_owner = authenticate_resource_owner(client, request, &authenticator)

          request.invalid_grant! if resource_owner.nil?

          token = GrapeOAuth2.config.access_token_class.create_for(client, resource_owner)
          token.to_bearer_token
        end
      end
    end
  end
end
