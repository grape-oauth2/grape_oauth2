module GrapeOAuth2
  class TokenResponse < Base
    def access_token
      @access_token ||= JSON.parse(body.first)
    end
  end
end
