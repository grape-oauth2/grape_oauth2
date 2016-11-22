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

          GrapeOAuth2::Responses::Authorization.new(authorization.call(env))
        rescue Rack::OAuth2::Server::Authorize::BadRequest => error
          error_response(error)
        end

        private

        def error_response(error)
          response = Rack::Response.new
          response.status = error.status
          response.header['Content-Type'] = 'application/json'
          response.write(JSON.dump(Rack::OAuth2::Util.compact_hash(error.protocol_params)))

          GrapeOAuth2::Responses::Authorization.new(response.finish)
        end

        def execute_default(request, response)
          GrapeOAuth2::Strategies::AuthorizationCode.process(request, response)
        end
      end
    end
  end
end
