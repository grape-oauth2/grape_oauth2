module GrapeOAuth2
  module Helpers
    module OAuthParams
      extend ::Grape::API::Helpers

      # Params are optional in order to process them correctly in accordance
      # with the RFC 6749 (invalid_client, unsupported_grant_type, etc.)
      params :oauth_token_params do
        optional :grant_type, type: String, desc: 'Grant type'
        optional :code, type: String, desc: 'Authorization code'
        optional :client_id, type: String, desc: 'Client ID'
        optional :client_secret, type: String, desc: 'Client secret'
        optional :refresh_token, type: String, desc: 'Refresh Token'
      end

      params :oauth_authorization_params do
        optional :response_type, type: String, desc: 'Response type'
        optional :client_id, type: String, desc: 'Client ID'
        optional :redirect_uri, type: String, desc: 'Redirect URI'
        optional :scope, type: String, desc: 'Authorization scopes'
        optional :state, type: String, desc: 'State'
      end
    end
  end
end
