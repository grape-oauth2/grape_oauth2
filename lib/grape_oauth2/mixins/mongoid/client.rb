module GrapeOAuth2
  module Mongoid
    module Client
      extend ActiveSupport::Concern

      included do
        include ::Mongoid::Document
        include ::Mongoid::Timestamps

        field :name, type: String
        field :key, type: String
        field :secret, type: String
        field :redirect_uri, type: String

        before_validation :generate_keys, on: :create

        def self.authenticate(key, secret = nil)
          if secret.nil?
            Application.find_by(key: key)
          else
            Application.find_by(key: key, secret: secret)
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
