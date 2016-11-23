module GrapeOAuth2
  module ActiveRecord
    module Client
      extend ActiveSupport::Concern

      included do
        has_many :access_tokens, class_name: GrapeOAuth2.config.access_token_class_name, foreign_key: :client_id

        validates :key, :secret, presence: true
        validates :key, uniqueness: true

        before_validation :generate_keys, on: :create

        def self.authenticate(key, secret = nil)
          if secret.nil?
            find_by(key: key)
          else
            find_by(key: key, secret: secret)
          end
        end

        protected

        def generate_keys
          self.key = GrapeOAuth2::UniqueToken.generate if key.nil? || key.empty?
          self.secret = GrapeOAuth2::UniqueToken.generate if secret.nil? || secret.empty?
        end
      end
    end
  end
end
