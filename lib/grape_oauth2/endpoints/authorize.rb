module GrapeOAuth2
  module Endpoints
    class Authorize < ::Grape::API
      helpers GrapeOAuth2::Helpers::OAuthParams

      namespace :oauth do
        params do
          use :oauth_authorization_params
        end

        get :authorize do
          raise NotImplemented
        end
      end
    end
  end
end
