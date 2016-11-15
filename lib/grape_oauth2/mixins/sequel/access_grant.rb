module GrapeOAuth2
  module Sequel
    module AccessGrant
      extend ActiveSupport::Concern

      included do
        plugin :validation_helpers
        plugin :timestamps

        many_to_one :client, class: GrapeOAuth2.config.client_class_name, key: :client_id
        many_to_one :resource_owner, class: GrapeOAuth2.config.resource_owner_class_name, key: :resource_owner_id

        def before_validation
          if new?
            generate_token
            setup_expiration
          end

          super
        end

        class << self
          def create_for(client, resource_owner, redirect_uri, scopes = nil)
            create(
              client_id: client.id,
              resource_owner_id: resource_owner && resource_owner.id,
              redirect_uri: redirect_uri,
              scopes: scopes.to_s
            )
          end
        end

        def validate
          super
          validates_presence [:token, :client_id]
          validates_unique [:token]
        end

        def expired?
          expires_at && Time.now.utc > expires_at
        end

        def revoked?
          revoked_at && revoked_at <= Time.now.utc
        end

        def revoke!(revoked_at = Time.now)
          set(revoked_at: revoked_at.utc)
          save(columns: [:revoked_at], validate: false)
        end

        protected

        def generate_token
          self.token = SecureRandom.hex(16)
        end

        def setup_expiration
          self.expires_at = Time.now.utc + GrapeOAuth2.config.code_lifetime if expires_at.nil?
        end
      end
    end
  end
end
