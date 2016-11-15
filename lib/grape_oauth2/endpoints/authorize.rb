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
          GrapeOAuth2::Generators::Authorization.generate_for(env)
        end
      end
    end
  end
end
