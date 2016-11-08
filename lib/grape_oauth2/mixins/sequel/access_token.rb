module GrapeOAuth2
  module Sequel
    module AccessToken
      extend ActiveSupport::Concern

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
          validates_presence [:token, :client_id]
          validates_unique [:token]
        end

        dataset_module do
          def active
            where(revoked_at: nil)
          end

          def by_refresh_token(refresh_token)
            first(refresh_token: refresh_token)
          end
        end

        class << self
          def create_for(client, resource_owner)
            create(client_id: client.id, resource_owner_id: resource_owner && resource_owner.id)
          end

          def authenticate(token, token_type = :access_token)
            if token_type.to_sym == :access_token
              active.first(token: token)
            else
              active.first(refresh_token: token)
            end
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

        def revoke!(revoked_at = Time.now)
          set(revoked_at: revoked_at.utc)
          save(columns: [:revoked_at], validate: false)
        end

        def accessible?
          !expired? && !revoked?
        end

        def to_bearer_token
          Rack::OAuth2::AccessToken::Bearer.new(
            access_token: token,
            expires_in: expires_in_seconds.to_i,
            refresh_token: refresh_token
          )
        end

        protected

        def generate_tokens
          self.token = SecureRandom.hex(16)
          self.refresh_token = SecureRandom.hex(16) if GrapeOAuth2.config.issue_refresh_token
        end

        def setup_expiration
          self.expires_at = Time.now.utc + GrapeOAuth2.config.token_lifetime if expires_at.nil?
        end
      end
    end
  end
end
