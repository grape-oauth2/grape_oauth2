module GrapeOAuth2
  module Strategies
    class RefreshToken < Base
      def process(request, &authenticator)
        client = authenticate_client!(request, &authenticator)

        request.invalid_client! unless client

        raise NotImplemented
        # TODO
        token = GrapeOAuth2.config.access_token_class.by_refresh_token(refresh_token)
        token.to_bearer_token
      end
    end
  end
end
