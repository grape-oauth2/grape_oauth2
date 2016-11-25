module Grape
  module OAuth2
    module Responses
      class Token < Base
        def access_token
          @access_token ||= body
        end
      end
    end
  end
end
