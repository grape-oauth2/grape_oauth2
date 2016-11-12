module GrapeOAuth2
  module Endpoints
    class Token < ::Grape::API
      helpers GrapeOAuth2::Helpers::OAuthParams

      namespace :oauth do
        # @see https://tools.ietf.org/html/rfc6749#section-3.2
        #
        desc 'OAuth 2.0 Token Endpoint'

        params do
          use :oauth_token_params
        end

        post :token do
          token_response = GrapeOAuth2::Generators::Token.generate_for(env)

          # Status
          status token_response.status

          # Headers
          token_response.headers.each do |key, value|
            header key, value
          end

          # Body
          body token_response.access_token
        end

        desc 'OAuth 2.0 Token Revocation'

        params do
          use :oauth_token_revocation_params
        end

        post :revoke do
          request = Rack::OAuth2::Server::Token::Request.new(env)

          # The authorization server, if applicable, first authenticates the client
          # and checks its ownership of the provided token.
          client = GrapeOAuth2::Strategies::Base.authenticate_client(request)
          request.invalid_client! if client.nil?

          access_token = GrapeOAuth2.config.access_token_class.authenticate(params[:token],
                                                                            type: params[:token_type_hint])

          if access_token
            if access_token.client
              access_token.revoke! if client && client == access_token.client
            else
              # Access token is public
              access_token.revoke!
            end
          end

          # The authorization server responds with HTTP status code 200 if the token
          # has been revoked successfully or if the client submitted an invalid
          # token.
          #
          # @see https://tools.ietf.org/html/rfc7009#section-2.2 Revocation Response
          #
          status 200
          {}
        end
      end
    end
  end
end
