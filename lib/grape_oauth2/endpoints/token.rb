module GrapeOAuth2
  module Endpoints
    class Token < ::Grape::API
      helpers GrapeOAuth2::Helpers::OAuthParams

      namespace :oauth do
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

        params do
          requires :token, type: String, desc: 'The token that the client wants to get revoked'
          optional :token_type_hint, type: String, values: %w(access_token refresh_token), default: 'access_token',
                                     desc: 'A hint about the type of the token submitted for revocation'
        end

        post :revoke do
          access_token = GrapeOAuth2.config.access_token_class.authenticate(params[:token], params[:token_type_hint])

          # TODO: The authorization server, if applicable, first authenticates the client
          # and checks its ownership of the provided token.
          if access_token
            # if current_access_token.client_id.nil? || current_access_token.client_id.
            access_token.revoke!
          end

          # @see https://tools.ietf.org/html/rfc7009#section-2.2 Revocation Response
          # The authorization server responds with HTTP status code 200 if the token
          # has been revoked successfully or if the client submitted an invalid
          # token
          status 200
          {}
        end
      end
    end
  end
end
