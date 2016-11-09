module GrapeOAuth2
  module Strategies
    class Base
      class << self
        def authenticate_client(request)
          if block_given?
            yield request
          else
            config.client_class.authenticate(request.client_id, request.client_secret)
          end
        end

        def authenticate_resource_owner(client, request)
          if block_given?
            yield client, request
          else
            resource_owner = config.resource_owner_class
            resource_owner.oauth_authenticate(client, request.username, request.password)
          end
        end

        def config
          GrapeOAuth2.config
        end

        def scopes_from(request)
          return nil if request.scope.nil?

          Array(request.scope).join(' ')
        end
      end
    end
  end
end
