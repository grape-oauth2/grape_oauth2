module GrapeOAuth2
  module ActiveRecord
    module AccessToken
      extend ActiveSupport::Concern

      included do
        belongs_to :client, class_name: GrapeOAuth2.config.client_class, foreign_key: :client_id
        belongs_to :resource_owner, class_name: GrapeOAuth2.config.resource_owner_class, foreign_key: :resource_owner_id

        validates :client_id, presence: true
        validates :token, presence: true, uniqueness: true

        before_validation :generate_tokens, on: :create
        before_validation :setup_expiration, on: :create

        class << self
          def create_for(client, resource_owner)
            create(client_id: client.id, resource_owner_id: resource_owner && resource_owner.id)
          end

          def authenticate(token, type: :access_token)
            if type && type.to_sym == :refresh_token
              find_by(refresh_token: token.to_s)
            else
              find_by(token: token.to_s)
            end
          end
        end

        def expired?
          !expires_at.nil? && Time.now.utc > expires_at
        end

        def revoked?
          !revoked_at.nil? && revoked_at <= Time.now.utc
        end

        def revoke!(revoked_at = Time.now)
          update_column :revoked_at, revoked_at.utc
        end

        def to_bearer_token
          Rack::OAuth2::AccessToken::Bearer.new(
            access_token: token,
            expires_in: expires_at && GrapeOAuth2.config.token_lifetime.to_i,
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
