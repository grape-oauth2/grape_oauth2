module Grape
  module OAuth2
    module Strategies
      # Refresh Token strategy class.
      # Processes request and respond with Access Token.
      class RefreshToken < Base
        class << self
          # Processes Refresh Token request.
          def process(request)
            client = authenticate_client(request)

            request.invalid_client! if client.nil?

            refresh_token = config.access_token_class.authenticate(request.refresh_token, type: :refresh_token)
            request.invalid_grant! if refresh_token.nil?
            request.unauthorized_client! if refresh_token && refresh_token.client != client

            token = config.access_token_class.create_for(client, refresh_token.resource_owner)
            run_on_refresh_callback(refresh_token) if config.on_refresh_runnable?

            expose_to_bearer_token(token)
          end

          private

          # Invokes custom callback on Access Token refresh.
          # If callback is a proc, then call it with token.
          # If access token responds to callback value (symbol for example), then call it from the token.
          #
          # @param access_token [Object] Access Token instance
          #
          def run_on_refresh_callback(access_token)
            callback = config.on_refresh

            if callback.respond_to?(:call)
              callback.call(access_token)
            elsif access_token.respond_to?(callback)
              access_token.send(callback)
            else
              raise ArgumentError, ":on_refresh is not a block and Access Token class doesn't respond to #{callback}!"
            end
          end
        end
      end
    end
  end
end
