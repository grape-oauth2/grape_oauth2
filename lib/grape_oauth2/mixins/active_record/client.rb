module GrapeOAuth2
  module ActiveRecord
    module Client
      extend ActiveSupport::Concern

      included do
        has_many :access_tokens, class_name: GrapeOAuth2.config.access_token_class

        validates :key, :secret, presence: true
        validates :key, uniqueness: true

        before_validation :generate_keys, on: :create

        def self.authenticate(key, secret)
          find_by(key: key, secret: secret)
        end

        private

        def generate_keys
          self.key = SecureRandom.hex(16) if key.blank?
          self.secret = SecureRandom.hex(16) if secret.blank?
        end
      end
    end
  end
end
