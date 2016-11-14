module GrapeOAuth2
  class Scopes
    attr_reader :scopes

    def initialize(scopes)
      @scopes = to_array(scopes || [])
    end

    def valid_for?(access_token)
      scopes.empty? || present_in?(access_token.scopes)
    end

    private

    def present_in?(token_scopes)
      required_scopes = Set.new(to_array(scopes))
      authorized_scopes = Set.new(to_array(token_scopes))

      authorized_scopes >= required_scopes
    end

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
