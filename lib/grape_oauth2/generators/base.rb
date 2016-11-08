module GrapeOAuth2
  module Generators
    class Base
      class << self
        def allowed_grants
          config.allowed_grant_types
        end

        def config
          GrapeOAuth2.config
        end
      end
    end
  end
end
