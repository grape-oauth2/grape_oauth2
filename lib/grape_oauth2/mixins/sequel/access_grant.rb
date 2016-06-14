module GrapeOAuth2
  module Sequel
    module AccessGrant
      extend ActiveSupport::Concern

      # TODO: make as plugin
      included do
        plugin :validation_helpers
        plugin :timestamps

        many_to_one :client, class: GrapeOAuth2.config.client_class, key: :client_id
        many_to_one :resource_owner, class: GrapeOAuth2.config.resource_owner_class, key: :resource_owner_id

        def before_validation
          if new?
            generate_token
            setup_expiration
          end

          super
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

        def revoke!(clock = Time)
          set(revoked_at: clock.now.utc)
          save(columns: [:revoked_at], validate: false)
        end

        def accessible?
          !expired? && !revoked?
        end

        protected

        def generate_token
          self.token = SecureRandom.hex(16)
        end

        def setup_expiration
          self.expires_at = Time.now.utc + GrapeOAuth2.config.grant_lifetime if expires_at.nil?
        end
      end
    end
  end
end
