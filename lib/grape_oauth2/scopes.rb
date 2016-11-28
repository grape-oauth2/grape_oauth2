module Grape
  module OAuth2
    # OAuth2 helper for scopes validation
    # (between requested and presented in Access Token).
    class Scopes
      # @attr [Array] scopes
      #   array of scopes
      attr_reader :scopes

      def initialize(scopes)
        @scopes = to_array(scopes || [])
      end

      # Check if requested scopes (passed and processed in initialization)
      # are presented in the Access Token.
      #
      # @param access_token [Object]
      #   instance of the Access Token class that responds to `scopes`
      #
      # @return [Boolean]
      #   true if requested scopes are empty or present in access token scopes
      #   and false in other cases
      def valid_for?(access_token)
        scopes.empty? || present_in?(access_token.scopes)
      end

      private

      def present_in?(token_scopes)
        required_scopes = Set.new(to_array(scopes))
        authorized_scopes = Set.new(to_array(token_scopes))

        authorized_scopes >= required_scopes
      end

      # Converts scopes set to the array.
      #
      # @param scopes [Array, String, #to_a]
      #   string, array or object that responds to `to_a`
      # @return [Array<String>]
      #   array of scopes
      #
      def to_array(scopes)
        return [] if scopes.nil?

        collection = if scopes.is_a?(Array) || scopes.respond_to?(:to_a)
                       scopes.to_a
                     elsif scopes.is_a?(String)
                       scopes.split
                     else
                       raise ArgumentError, 'scopes class is not supported!'
                     end

        collection.map(&:to_s)
      end
    end
  end
end
