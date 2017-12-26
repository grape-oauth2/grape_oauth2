module Grape
  module OAuth2
    module Mongoid
      # Grape::OAuth2 Client role mixin for Mongoid ORM.
      # Includes all the required API, associations, validations and callbacks.
      module Client
        extend ActiveSupport::Concern

        included do
          include ::Mongoid::Document
          include ::Mongoid::Timestamps

          has_many :access_tokens, class_name: Grape::OAuth2.config.access_token_class_name,
                                   foreign_key: :client_id, dependent: :delete

          field :name, type: String
          field :key, type: String
          field :secret, type: String
          field :redirect_uri, type: String

          before_validation :generate_keys, on: :create

          validates :key, :secret, presence: true
          validates :key, uniqueness: true

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
