module GrapeOAuth2
  class Configuration
    module Validation
      # Checks configuration to be set correctly (required classes
      # must be defined and implement specific set of API methods).
      def check!
        check_required_classes!
        check_required_classes_api!
      end

      private

      REQUIRED_CLASSES_API = {
        access_token_class: {
          class_methods: %i(authenticate create_for),
          instance_methods: %i(expired? revoked? revoke! to_bearer_token)
        },
        client_class: {
          class_methods: %i(authenticate)
        },
        resource_owner_class: {
          class_methods: %i(oauth_authenticate)
        }
      }.freeze

      def check_required_classes!
        required_classes = (REQUIRED_CLASSES_API.keys + [:scopes_validator_class])

        required_classes.each do |klass|
          begin
            object = send(klass)
          rescue NoMethodError
            raise Error, "'#{klass}' must be defined!" if object.nil? || !defined?(object)
          end
        end
      end

      def check_required_classes_api!
        REQUIRED_CLASSES_API.each do |klass, api_methods|
          check_class_methods(klass, api_methods[:class_methods])
          check_instance_methods(klass, api_methods[:instance_methods])
        end
      end

      def check_class_methods(klass, required_methods)
        (required_methods || []).each do |method|
          method_exist = send(klass).respond_to?(method)
          raise APIMissing, "Class method '#{method}' must be defined for the '#{klass}'!" unless method_exist
        end
      end

      def check_instance_methods(klass, required_methods)
        (required_methods || []).each do |method|
          unless send(klass).method_defined?(method)
            raise APIMissing, "Instance method '#{method}' must be defined for the '#{klass}'!"
          end
        end
      end
    end
  end
end
