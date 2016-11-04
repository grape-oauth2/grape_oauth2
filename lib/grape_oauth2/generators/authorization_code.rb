module GrapeOAuth2
  module Generators
    class AuthorizationCode < Base
      class << self
        def generate_for(env, &_block)
          authorization = Rack::OAuth2::Server::Authorize.new do |request, response|
            if block_given?
              yield request, response
            else
              execute_default(request, response)
            end
          end

          authorization.call(env)
        end

        def authenticate_client!(request)
          GrapeOAuth2.config.client_class.authenticate(request.client_id)
        end

        private

        def execute_default(request, response)
          client = authenticate_client!(request) || request.bad_request!
          response.redirect_uri = request.verify_redirect_uri!(client.redirect_uri) # TODO: split URIs

          request.invalid_request! if request.response_type != :code

          # Move to Strategy Class
          # TODO: verify scopes if they valid
          # scopes = request.scope
          # request.invalid_scope! "Unknown scope: #{scope}"

          # TODO: create access grant
          # access_grant = AccessGrant.create(
          #    client: client,
          #    redirect_uri: response.redirect_uri
          #    scopes: scopes
          # )

          # response.code = access_grant.token
          response.approve!
        end
      end
    end
  end
end
