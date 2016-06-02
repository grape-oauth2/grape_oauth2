module GrapeOAuth2
  module Helpers
    module OAuthParams
      extend ::Grape::API::Helpers

      # Params are optional in order to process them correctly in accordance
      # with the RFC 6749 (invalid_client, unsupported_grant_type, etc.)
      params :oauth_token_params do
        optional :grant_type, type: String, desc: 'The grant type'
        optional :code, type: String, desc: 'The authorization code'
        optional :client_id, type: String, desc: 'The client id'
        optional :client_secret, type: String, desc: 'The client secret'
        optional :refresh_token, type: String, desc: 'The refresh_token'
      end
    end
  end
end
