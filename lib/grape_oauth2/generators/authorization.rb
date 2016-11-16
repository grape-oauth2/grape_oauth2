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

          GrapeOAuth2::AuthorizationResponse.new(authorization.call(env))
        rescue Rack::OAuth2::Server::Authorize::BadRequest => error
          error_response(error)
        end

        private

        def error_response(error)
          # Add other data to the response!
          response = Rack::Response.new([{ error: error.error, description: error.description }], error.status)
          GrapeOAuth2::AuthorizationResponse.new([error.status, {}, Rack::BodyProxy.new(response)])
        end

        def execute_default(request, response)
          GrapeOAuth2::Strategies::AuthorizationCode.process(request, response)
        end
      end
    end
  end
end
