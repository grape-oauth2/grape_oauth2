module GrapeOAuth2
  module Strategies
    class ClientCredentials < Base
      class << self
        def process(request, &_authenticator)
          client = if block_given?
                     yield request
                   else
                     authenticate_client!(request)
                   end

          request.invalid_client! unless client

          token = GrapeOAuth2.config.access_token_class.create_for(client, nil)
          token.to_bearer_token
        end
      end
    end
  end
end
