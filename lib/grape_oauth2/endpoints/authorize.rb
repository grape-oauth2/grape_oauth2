module GrapeOAuth2
  module Endpoints
    class Authorize < ::Grape::API
      helpers GrapeOAuth2::Helpers::OAuthParams

      namespace :oauth do
        desc 'OAuth 2.0 Authorization Endpoint'

        params do
          use :oauth_authorization_params
        end

        post :authorize do
          response = GrapeOAuth2::Generators::Authorization.generate_for(env)

          # Status
          status response.status

          # Headers
          response.headers.each do |key, value|
            header key, value
          end

          # Body
          body response.body
        end
      end
    end
  end
end
