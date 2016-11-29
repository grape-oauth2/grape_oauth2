module Grape
  module OAuth2
    module Generators
      # Base class for Grape::OAuth2 generators.
      # Grape::OAuth2 generators processes the requests and
      # generates responses with Access Token or Authorization Code.
      class Base
        class << self
          # Allowed grant types from the Grape::OAuth2 configuration.
          #
          # @return [Array]
          #   allowed grant types
          #
          def allowed_grants
            config.allowed_grant_types
          end

          # Short getter for Grape::OAuth2 configuration.
          def config
            Grape::OAuth2.config
          end
        end
      end
    end
  end
end
