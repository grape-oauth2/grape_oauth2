module Grape
  module OAuth2
    # Grape::OAuth2 accessors for configured classes.
    module ClassAccessors
      def access_token_class
        @_access_token_class ||= access_token_class_name.constantize
      end

      def resource_owner_class
        @_resource_owner_class ||= resource_owner_class_name.constantize
      end

      def client_class
        @_client_class ||= client_class_name.constantize
      end

      def access_grant_class
        @_access_grant_class ||= access_grant_class_name.constantize
      end

      def scopes_validator
        scopes_validator_class_name.constantize
      end

      def token_generator
        token_generator_class_name.constantize
      end
    end
  end
end
