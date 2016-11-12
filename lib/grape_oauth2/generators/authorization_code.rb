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

        def authenticate_client(request)
          config.client_class.authenticate(request.client_id)
        end

        private

        def execute_default(request, response)
          client = authenticate_client(request) || request.bad_request!
          response.redirect_uri = request.verify_redirect_uri!(client.redirect_uri)

          # Move to Strategy Class
          # TODO: verify scopes if they valid
          # scopes = request.scope
          # request.invalid_scope! "Unknown scope: #{scope}"

          case request.response_type
          when :code
            # resource owner can't be nil!
            authorization_code = config.access_grant_class.create_for(client, resource_owner, response.redirect_uri)
            response.code = authorization_code.token
          when :token
            # resource owner can't be nil!
            access_token = config.access_token_class.create_for(client, nil, scopes_from(request))
            response.access_token = access_token.to_bearer_token
          else
            request.unsupported_response_type!
          end

          response.approve!
          response
        end
      end
    end
  end
end
