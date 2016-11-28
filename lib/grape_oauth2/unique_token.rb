module Grape
  module OAuth2
    # OAuth2 helper for generation of unique token values.
    # Can process custom payload and options.
    module UniqueToken
      # Generates unique token value.
      #
      # @param _payload [Hash]
      #   payload
      # @param options [Hash]
      #   options for generator
      #
      # @return [String]
      #   unique token value
      def self.generate(_payload = {}, options = {})
        SecureRandom.hex(options.delete(:size) || 32)
      end
    end
  end
end
