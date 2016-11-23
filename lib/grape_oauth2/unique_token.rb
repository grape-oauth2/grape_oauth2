module GrapeOAuth2
  module UniqueToken
    def self.generate(_attributes = {}, options = {})
      SecureRandom.hex(options.delete(:size) || 32)
    end
  end
end
