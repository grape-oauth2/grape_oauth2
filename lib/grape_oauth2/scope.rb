module GrapeOAuth2
  class Scope
    class << self
      def sufficient?(token_scopes, scopes)
        # if no any scopes required, the scopes of token is sufficient.
        return true if scopes.blank?

        required_scopes = Set.new(Array.wrap(scopes))
        authorized_scopes = Set.new(token_scopes)

        authorized_scopes >= required_scopes
      end
    end
  end
end
