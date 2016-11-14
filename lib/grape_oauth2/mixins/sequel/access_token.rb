module GrapeOAuth2
  module Sequel
    module AccessToken
      extend ActiveSupport::Concern

      included do
        plugin :validation_helpers
        plugin :timestamps

        many_to_one :client, class: GrapeOAuth2.config.client_class_name, key: :client_id
        many_to_one :resource_owner, class: GrapeOAuth2.config.resource_owner_class_name, key: :resource_owner_id

        def before_validation
          if new?
            generate_tokens
            setup_expiration
          end

          super
        end

        def validate
          super
          validates_presence [:token, :client_id]
          validates_unique [:token]
        end

        class << self
          def create_for(client, resource_owner, scopes = nil)
            create(
              client_id: client.id,
              resource_owner_id: resource_owner && resource_owner.id,
              scopes: scopes.to_s
            )
          end

          def authenticate(token, type: :access_token)
            if type && type.to_sym == :refresh_token
              first(refresh_token: token.to_s)
            else
              first(token: token.to_s)
            end
          end
        end

        def expired?
          !expires_at.nil? && Time.now.utc > expires_at.utc
        end

        def revoked?
          !revoked_at.nil? && revoked_at <= Time.now.utc
        end

        def revoke!(revoked_at = Time.now)
          set(revoked_at: revoked_at.utc)
          save(columns: [:revoked_at], validate: false)
        end

        def to_bearer_token
          Rack::OAuth2::AccessToken::Bearer.new(
            access_token: token,
            expires_in: expires_at && GrapeOAuth2.config.token_lifetime.to_i,
            refresh_token: refresh_token,
            scope: scopes
          )
        end

        protected

        def generate_tokens
          self.token = SecureRandom.hex(16) if token.blank?
          self.refresh_token = SecureRandom.hex(16) if GrapeOAuth2.config.issue_refresh_token
        end

        def setup_expiration
          self.expires_at = Time.now + GrapeOAuth2.config.token_lifetime if expires_at.nil?
        end
      end
    end
  end
end
