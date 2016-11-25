module Grape
  module OAuth2
    module Sequel
      module AccessToken
        extend ActiveSupport::Concern

        included do
          plugin :validation_helpers
          plugin :timestamps

          many_to_one :client, class: Grape::OAuth2.config.client_class_name, key: :client_id
          many_to_one :resource_owner, class: Grape::OAuth2.config.resource_owner_class_name, key: :resource_owner_id

          def before_validation
            if new?
              setup_expiration
              generate_tokens
            end

            super
          end

          def validate
            super
            validates_presence :token
            validates_unique :token
          end

          class << self
            def create_for(client, resource_owner, scopes = nil)
              create(
                client: client,
                resource_owner: resource_owner,
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
            {
              access_token: token,
              expires_in: expires_at && Grape::OAuth2.config.access_token_lifetime.to_i,
              refresh_token: refresh_token,
              scope: scopes
            }
          end

          protected

          def generate_tokens
            self.token = Grape::OAuth2.config.token_generator.generate(values) if token.blank?
            self.refresh_token = Grape::OAuth2::UniqueToken.generate if Grape::OAuth2.config.issue_refresh_token
          end

          def setup_expiration
            expires_in = Grape::OAuth2.config.access_token_lifetime
            self.expires_at = Time.now + expires_in if expires_at.nil? && !expires_in.nil?
          end
        end
      end
    end
  end
end
