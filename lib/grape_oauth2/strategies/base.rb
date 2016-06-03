module GrapeOAuth2
  module Strategies
    class Base
      class << self
        def authenticate_client!(request)
          GrapeOAuth2.config.client_class.authenticate(request.client_id, request.client_secret)
        end

        def authenticate_resource_owner!(client, request)
          resource_owner = GrapeOAuth2.config.resource_owner_class
          resource_owner.oauth_authenticate(client, request.username, request.password)
        end
      end
    end
  end
end
