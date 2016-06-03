module GrapeOAuth2
  module Generators
    class Base
      class << self
        def allowed_grants
          GrapeOAuth2.config.allowed_grant_types
        end
      end
    end
  end
end
