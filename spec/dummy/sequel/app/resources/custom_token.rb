module Twitter
  module Resources
    class CustomToken < ::Grape::API
      helpers GrapeOAuth2::Helpers::OAuthParams

      namespace :oauth do
        params do
          use :oauth_token_params
        end

        post :custom_token do
          token_response = GrapeOAuth2::Generators::Token.generate_for(env) do |request, response|
            # Custom client authentication:
            client = Application.find(key: request.client_id, name: 'Admin')
            request.invalid_client! if client.nil?

            resource_owner = GrapeOAuth2::Strategies::Base.authenticate_resource_owner(client, request)
            request.invalid_grant! if resource_owner.nil?

            token = AccessToken.create_for(client, resource_owner, request.scope)
            response.access_token = GrapeOAuth2::Strategies::Base.expose_to_bearer_token(token)
          end

          status token_response.status

          token_response.headers.each do |key, value|
            header key, value
          end

          body token_response.access_token
        end
      end
    end
  end
end
