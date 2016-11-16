require 'spec_helper'

describe GrapeOAuth2::Configuration do
  let(:config) { described_class.new }

  # Refactor: Mock it
  class CustomClient
    def self.authenticate(key, secret = nil)
      'Test'
    end
  end

  class CustomAccessToken
    def self.create_for(client, resource_owner, scopes = nil)
    end

    def self.authenticate(token, type: :access_token)
      'Test'
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
      'Test'
    end
  end

  context 'default config' do
    it 'setup config with default values' do
      expect(config.token_lifetime).to eq(7200)
      expect(config.code_lifetime).to eq(7200)

      expect(config.realm).to eq(GrapeOAuth2::Configuration::DEFAULT_REALM)
      expect(config.allowed_grant_types).to eq(%w(password client_credentials))

      expect(config.issue_refresh_token).to be_falsey
      expect(config.on_refresh).to eq(:nothing)

      expect(config.scopes_validator_class_name).to eq(GrapeOAuth2::Scopes.name)
    end
  end

  context 'custom config' do
    class CustomScopesValidator
      def initialize(scopes)
        @scopes = scopes
      end

      def valid_for?(access_token)
        false
      end
    end

    before do
      config.access_token_class_name = 'CustomAccessToken'
      config.resource_owner_class_name = 'CustomResourceOwner'
      config.client_class_name = 'CustomClient'
      config.access_grant_class_name = 'Object'
      config.scopes_validator_class_name = 'CustomScopesValidator'
    end

    it 'invokes custom scopes validator' do
      expect(config.scopes_validator_class.new([]).valid_for?(nil)).to be_falsey
    end

    it 'works with custom Access Token class' do
      expect(config.access_token_class.authenticate('')).to eq('Test')
    end

    it 'works with custom Client class' do
      expect(config.client_class.authenticate('')).to eq('Test')
    end

    it 'works with custom Resource Owner class' do
      expect(config.resource_owner_class.oauth_authenticate('', '', '')).to eq('Test')
    end

    it 'works with custom token authenticator' do
      # before
      GrapeOAuth2.configure do |config|
        config.token_authenticator do |request|
          raise ArgumentError, 'Test'
        end
      end

      expect { config.token_authenticator.call }.to raise_error(ArgumentError)

      # after
      GrapeOAuth2.configure do |config|
        config.token_authenticator = config.default_token_authenticator
      end
    end

    it 'works with custom on_refresh callback' do
      token = AccessToken.create

      # before
      GrapeOAuth2.configure do |config|
        config.on_refresh do |access_token|
          access_token.update(scopes: 'test')
        end
      end

      expect {
        GrapeOAuth2::Strategies::RefreshToken.send(:on_refresh_callback, token)
      }.to change { token.scopes }.to('test')

      # after
      GrapeOAuth2.configure do |config|
        config.on_refresh = :nothing
      end
    end
  end

  context 'validation' do
    context 'with invalid config options' do
      it 'raises an error' do
        expect { config.check! }.to raise_error(GrapeOAuth2::Configuration::Error)
      end
    end

    context 'with valid config options' do
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
