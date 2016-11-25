module Grape
  module OAuth2
    module UniqueToken
      def self.generate(_payload = {}, options = {})
        SecureRandom.hex(options.delete(:size) || 32)
      end
    end
  end
end
