module GrapeOAuth2
  class TokenGenerator
    def self.generate_for(env, &block)
      TokenGenerator.new.execute(env, &block)
    end

    def execute(env, &_block)
      token = Rack::OAuth2::Server::Token.new do |request, response|
        request.unsupported_grant_type! unless allowed_grants.include?(request.grant_type.to_s)

        if block_given?
          yield request, response
        else
          execute_default(request, response)
        end
      end

      GrapeOAuth2::TokenResponse.new(token.call(env))
    end

    def authenticate_client!(request)
      GrapeOAuth2.config.client_class.authenticate(request.client_id, request.client_secret)
    end

    private

    def allowed_grants
      GrapeOAuth2.config.allowed_grant_types
    end

    def execute_default(request, response)
      client = authenticate_client!(request)
      request.invalid_client! unless client

      strategy_class = "GrapeOAuth2::Strategies::#{request.grant_type.to_s.classify}".constantize
      response.access_token = strategy_class.process(client, request)
    end
  end
end
