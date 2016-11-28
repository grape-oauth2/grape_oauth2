module Grape
  module OAuth2
    module Generators
      # base class gor Grape::OAuth2 generators.
      class Base
        class << self
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
