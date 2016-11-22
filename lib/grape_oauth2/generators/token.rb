module GrapeOAuth2
  module Generators
    class Token < Base
      # Grant type => OAuth2 strategy class
      STRATEGY_CLASSES = {
        password: GrapeOAuth2::Strategies::Password,
        client_credentials: GrapeOAuth2::Strategies::ClientCredentials,
        refresh_token: GrapeOAuth2::Strategies::RefreshToken
      }.freeze

      class << self
        def generate_for(env, &_block)
          token = Rack::OAuth2::Server::Token.new do |request, response|
            request.unsupported_grant_type! unless allowed_grants.include?(request.grant_type.to_s)

            if block_given?
              yield request, response
            else
              execute_default(request, response)
            end
          end

          GrapeOAuth2::Responses::Token.new(token.call(env))
        end

        protected

        def execute_default(request, response)
          strategy = initialize_strategy(request.grant_type) || request.invalid_grant!
          response.access_token = strategy.process(request)
        end

        def initialize_strategy(grant_type)
          STRATEGY_CLASSES[grant_type]
        end
      end
    end
  end
end
