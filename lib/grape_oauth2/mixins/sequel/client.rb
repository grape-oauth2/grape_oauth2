module GrapeOAuth2
  module Sequel
    module Client
      extend ActiveSupport::Concern

      # TODO: Make as plugin
      included do
        plugin :validation_helpers
        plugin :timestamps

        one_to_many :access_tokens, class: GrapeOAuth2.config.access_token_class, key: :client_id
        one_to_many :refresh_tokens, class: GrapeOAuth2.config.access_token_class, key: :client_id do |set|
          set.where(revoked_at: nil).exclude(refresh_token: nil)
        end

        def before_validation
          generate_keys if new?
          super
        end

        def validate
          super
          validates_presence [:key, :secret]
          validates_unique [:key]
        end

        def self.authenticate(key, secret = nil)
          if secret.nil?
            find(key: key)
          else
            find(key: key, secret: secret)
          end
        end

        protected

        def generate_keys
          self.key = SecureRandom.hex(16) if key.nil? || key.empty?
          self.secret = SecureRandom.hex(16) if secret.nil? || secret.empty?
        end
      end
    end
  end
end
