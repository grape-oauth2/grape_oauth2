require 'spec_helper'

describe GrapeOAuth2::Configuration do
  context 'default config' do
    let(:config) { described_class.new }

    it 'setup config with default values' do
      expect(config.token_lifetime).to eq(7200)
      expect(config.code_lifetime).to eq(7200)

      expect(config.realm).to eq(GrapeOAuth2::Configuration::DEFAULT_REALM)
      expect(config.allowed_grant_types).to eq(%w(password client_credentials))

      expect(config.issue_refresh_token).to be_falsey
      expect(config.revoke_after_refresh).to be_falsey

      expect(config.scopes_validator_class_name).to eq(GrapeOAuth2::Scopes.name)
    end
  end

  context 'validation' do
    let(:config) { described_class.new }

    context 'with invalid config options' do
      it 'raises an error' do
        expect { config.check! }.to raise_error(GrapeOAuth2::Configuration::Error)
      end
    end

    context 'with valid config options' do
      # Refactor: Mock it
      class CustomClient
        def self.authenticate(key, secret = nil)
        end
      end

      class CustomAccessToken
        def self.create_for(client, resource_owner, scopes = nil)
        end

        def self.authenticate(token, type: :access_token)
        end

        def client
        end

        def resource_owner
        end

        def expired?
        end

        def revoked?
        end

        def revoke!(revoked_at = Time.now)
        end

        def to_bearer_token
        end
      end

      class CustomResourceOwner
        def self.oauth_authenticate(client, username, password)
        end
      end

      before do
        config.access_token_class_name = 'CustomAccessToken'
        config.resource_owner_class_name = 'CustomResourceOwner'
        config.client_class_name = 'CustomClient'
        config.access_grant_class_name = 'Object'
      end

      it 'successfully pass' do
        expect { config.check! }.not_to raise_error
      end
    end
  end
end
