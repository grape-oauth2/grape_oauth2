module GrapeOAuth2
  module ActiveRecord
    module AccessGrant
      extend ActiveSupport::Concern

      included do
        belongs_to :client, class_name: GrapeOAuth2.config.client_class, foreign_key: :client_id
        belongs_to :resource_owner, class_name: GrapeOAuth2.config.resource_owner_class, foreign_key: :resource_owner_id

        validates :resource_owner_id, :client_id, :redirect_uri, presence: true
        validates :token, presence: true, uniqueness: true

        before_validation :generate_token, on: :create
        before_validation :setup_expiration, on: :create

        def expired?
          expires_at && Time.now.utc > expires_at
        end

        def revoked?
          revoked_at && revoked_at <= Time.now.utc
        end

        def revoke!(revoked_at = Time.now)
          update_column :revoked_at, revoked_at.utc
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
