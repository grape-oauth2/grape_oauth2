module Grape
  module OAuth2
    module Mongoid
      module AccessGrant
        extend ActiveSupport::Concern

        included do
          include ::Mongoid::Document
          include ::Mongoid::Timestamps

          field :resource_owner_id, type: BSON::ObjectId
          field :client_id, type: BSON::ObjectId

          field :token, type: String
          field :scopes, type: String
          field :redirect_uri, type: String

          field :expires_at, type: DateTime

          belongs_to :client, class_name: Grape::OAuth2.config.client_class_name,
                              foreign_key: :client_id

          belongs_to :resource_owner, class_name: Grape::OAuth2.config.resource_owner_class_name,
                                      foreign_key: :resource_owner_id, optional: true # required!

          before_validation :generate_token, on: :create
          before_validation :setup_expiration, on: :create

          index({ token: 1 }, unique: true)
          index({ refresh_token: 1 }, unique: true, sparse: true)

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

          protected

          def generate_token
            self.token = Grape::OAuth2.config.token_generator.generate(attributes)
          end

          def setup_expiration
            self.expires_at = Time.now.utc + Grape::OAuth2.config.authorization_code_lifetime if expires_at.nil?
          end
        end
      end
    end
  end
end
