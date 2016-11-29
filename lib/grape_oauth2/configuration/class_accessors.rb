module Grape
  module OAuth2
    # Grape::OAuth2 accessors for configured classes.
    module ClassAccessors
      # Returns Access Token class by configured name
      def access_token_class
        @_access_token_class ||= access_token_class_name.constantize
      end

      # Returns Resource Owner class by configured name
      def resource_owner_class
        @_resource_owner_class ||= resource_owner_class_name.constantize
      end

      # Returns Client class by configured name
      def client_class
        @_client_class ||= client_class_name.constantize
      end

      # Returns Access Grant class by configured name
      def access_grant_class
        @_access_grant_class ||= access_grant_class_name.constantize
      end

      # Returns Scopes Validator class by configured name
      def scopes_validator
        scopes_validator_class_name.constantize
      end

      # Returns Token Generator class by configured name
      def token_generator
        token_generator_class_name.constantize
      end
    end
  end
end
