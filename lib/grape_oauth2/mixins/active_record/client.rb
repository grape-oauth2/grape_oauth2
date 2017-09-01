module Grape
  module OAuth2
    module ActiveRecord
      # Grape::OAuth2 Client role mixin for ActiveRecord.
      # Includes all the required API, associations, validations and callbacks.
      module Client
        extend ActiveSupport::Concern

        included do
          has_many :access_tokens, class_name: Grape::OAuth2.config.access_token_class_name, foreign_key: :client_id, dependent: :delete_all

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
            self.key = Grape::OAuth2::UniqueToken.generate if key.blank?
            self.secret = Grape::OAuth2::UniqueToken.generate if secret.blank?
          end
        end
      end
    end
  end
end
