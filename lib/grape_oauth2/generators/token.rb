module Grape
  module OAuth2
    module Generators
      # OAuth2 Token generator class.
      # Processes the request by required Grant Type and builds the response.
      class Token < Base
        # Grant type => OAuth2 strategy class
        STRATEGY_CLASSES = {
          password: Grape::OAuth2::Strategies::Password,
          client_credentials: Grape::OAuth2::Strategies::ClientCredentials,
          refresh_token: Grape::OAuth2::Strategies::RefreshToken
        }.freeze

        class << self
          # Generates Token Response based on the request.
          #
          # @return [Grape::OAuth2::Responses::Token] response
          #
          def generate_for(env, &_block)
            token = Rack::OAuth2::Server::Token.new do |request, response|
              request.unsupported_grant_type! unless allowed_grants.include?(request.grant_type.to_s)

              if block_given?
                yield request, response
              else
                execute_default(request, response)
              end
            end

            Grape::OAuth2::Responses::Token.new(token.call(env))
          end

          protected

          # Runs default Grape::OAuth2 functionality for Token endpoint.
          # In common it authenticates client (or/and any other objects) and
          # grants the Access Token or Auth Code.
          #
          # @param request [Rack::Request] request object
          # @param response [Rack::Response] response object
          #
          def execute_default(request, response)
            strategy = find_strategy(request.grant_type) || request.invalid_grant!
            response.access_token = strategy.process(request)
          end

          # Returns Grape::OAuth2 strategy class by Grant Type.
          #
          # @param grant_type [Symbol]
          #   grant type value
          #
          # @return [Password, ClientCredentials, RefreshToken]
          #   strategy class
          #
          def find_strategy(grant_type)
            STRATEGY_CLASSES[grant_type]
          end
        end
      end
    end
  end
end
