module Grape
  module OAuth2
    module Strategies
      # Auth Code strategy class.
      # Processes request and respond with Token or Code
      # (depend on requested response type).
      class AuthorizationCode < Base
        class << self
          def process(request, response)
            client = authenticate_client(request)
            request.bad_request! if client.nil?

            response.redirect_uri = request.verify_redirect_uri!(client.redirect_uri)

            # TODO: verify scopes if they valid
            # scopes = request.scope
            # request.invalid_scope! "Unknown scope: #{scope}"

            case request.response_type
            when :code
              # resource owner can't be nil!
              authorization_code = config.access_grant_class.create_for(client, nil, response.redirect_uri)
              response.code = authorization_code.token
            when :token
              # resource owner can't be nil!
              access_token = config.access_token_class.create_for(client, nil, scopes_from(request))
              response.access_token = expose_to_bearer_token(access_token)
            end

            response.approve!
            response
          end
        end
      end
    end
  end
end
