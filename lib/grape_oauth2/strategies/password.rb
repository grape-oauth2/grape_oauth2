module GrapeOAuth2
  module Strategies
    class Password < Base
      class << self
        def process(request, &_authenticator)
          client = authenticate_client!(request) || request.invalid_client!

          resource_owner = if block_given?
                             yield client, request
                           else
                             authenticate_resource_owner!(client, request)
                           end

          request.invalid_grant! unless resource_owner

          token = GrapeOAuth2.config.access_token_class.create_for(client, resource_owner)
          token.to_bearer_token
        end
      end
    end
  end
end
