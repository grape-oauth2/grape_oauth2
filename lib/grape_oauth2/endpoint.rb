module GrapeOAuth2
  class Endpoint < ::Grape::API
    namespace :oauth do
      # Params are optional in order to process them correctly in accordance
      # with the RFC 6749 (invalid_client, unsupported_grant_type, etc.)
      params do
        optional :grant_type, type: String, desc: 'The grant type'
        optional :code, type: String, desc: 'The authorization code'
        optional :client_id, type: String, desc: 'The client id'
        optional :client_secret, type: String, desc: 'The client secret'
        optional :refresh_token, type: String, desc: 'The refresh_token'
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
