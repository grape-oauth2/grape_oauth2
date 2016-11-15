module GrapeOAuth2
  module Generators
    class Authorization < Base
      class << self
        def generate_for(env, &_block)
          authorization = Rack::OAuth2::Server::Authorize.new do |request, response|
            if block_given?
              yield request, response
            else
              execute_default(request, response)
            end
          end

          authorization.call(env) # GrapeOAuth2::AuthorizationResponse.new(authorization.call(env))
        end

        private

        def execute_default(request, response)
          GrapeOAuth2::Strategies::AuthorizationCode.process(request, response)
        end
      end
    end
  end
end
