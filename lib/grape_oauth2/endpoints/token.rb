module GrapeOAuth2
  module Endpoints
    class Token < ::Grape::API
      helpers GrapeOAuth2::Helpers::OAuthParams

      namespace :oauth do
        params do
          use :oauth_token_params
        end

        post :token do
          token_response = GrapeOAuth2::TokenGenerator.generate_for(env)

          # Status
          status token_response.status

          # Headers
          token_response.headers.each do |key, value|
            header key, value
          end

          # Body
          body token_response.access_token
        end
      end
    end
  end
end
