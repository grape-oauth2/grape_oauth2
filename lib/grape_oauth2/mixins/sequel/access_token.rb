module GrapeOAuth2
  module Sequel
    module AccessToken
      extend ActiveSupport::Concern

      # TODO: make as plugin
      included do
        plugin :validation_helpers
        plugin :timestamps

        many_to_one :client, class: GrapeOAuth2.config.client_class, key: :client_id
        many_to_one :resource_owner, class: GrapeOAuth2.config.resource_owner_class, key: :resource_owner_id

        def before_validation
          if new?
            generate_tokens
            setup_expiration
          end

          super
        end

        def validate
          super
          validates_presence [:token, :resource_owner_id, :client_id, :expires_at]
          validates_unique [:token]
        end

        dataset_module do
          def active
            where(revoked_at: nil).where { expires_at >= Time.now.utc }
          end
        end

        class << self
          def create_for(client, resource_owner)
            create(resource_owner_id: resource_owner.id, client_id: client.id)
          end

          # TODO: check scopes?
          def authenticate(token)
            active.find(token: token)
          end
        end

        def expired?
          expires_at && Time.now.utc > expires_at
        end

        def expires_in_seconds
          return nil if expires_at.nil?
          GrapeOAuth2.config.token_lifetime
        end

        def revoked?
          revoked_at && revoked_at <= Time.now.utc
        end

        def revoke!(clock = Time)
          set(revoked_at: clock.now.utc)
          save(columns: [:revoked_at], validate: false)
        end

        def accessible?
          !expired? && !revoked?
        end

        def to_bearer_token
          Rack::OAuth2::AccessToken::Bearer.new(
            access_token: token,
            expires_in: expires_in_seconds.to_i
          )
          # TODO: what about refresh token ?
        end

        protected

        def generate_tokens
          self.token = SecureRandom.hex(16)
          self.refresh_token = SecureRandom.hex(16) if GrapeOAuth2.config.refresh_token
        end

        def setup_expiration
          self.expires_at = Time.now.utc + GrapeOAuth2.config.token_lifetime
        end
      end
    end
  end
end
