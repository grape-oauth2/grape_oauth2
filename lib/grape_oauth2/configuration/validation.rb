module Grape
  module OAuth2
    class Configuration
      # Validates Grape::OAuth2 configuration.
      module Validation
        # Checks configuration to be set correctly
        # (required classes must be defined and implement specific set of API).
        def check!
          check_required_classes!
          check_required_classes_api!
        end

        private

        # API mapping.
        # Classes, that represents OAuth2 roles, must have described methods.
        REQUIRED_CLASSES_API = {
          access_token_class: {
            class_methods: %i[authenticate create_for],
            instance_methods: %i[expired? revoked? revoke! to_bearer_token]
          },
          client_class: {
            class_methods: %i[authenticate]
          },
          token_generator: {
            class_methods: %i[generate]
          },
          scopes_validator: {
            instance_methods: %i[valid_for?]
          }
        }.freeze

        # Validates that required classes defined.
        def check_required_classes!
          REQUIRED_CLASSES_API.keys.each do |klass|
            begin
              object = send(klass)
            rescue NoMethodError
              raise Error, "'#{klass}' must be defined!" if object.nil? || !defined?(object)
            end
          end
        end

        # Validates that required classes have all the API.
        def check_required_classes_api!
          REQUIRED_CLASSES_API.each do |klass, api_methods|
            check_class_methods(klass, api_methods[:class_methods])
            check_instance_methods(klass, api_methods[:instance_methods])
          end
        end

        # Validates that required classes have required class methods.
        def check_class_methods(klass, required_methods)
          (required_methods || []).each do |method|
            method_exist = send(klass).respond_to?(method)
            raise APIMissing, "Class method '#{method}' must be defined for the '#{klass}'!" unless method_exist
          end
        end

        # Validates that required classes have required instance methods.
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
end
