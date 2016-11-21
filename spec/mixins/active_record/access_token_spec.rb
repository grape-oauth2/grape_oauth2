require 'spec_helper'

describe 'GrapeOAuth2::ActiveRecord::AccessToken', skip_if: ENV['ORM'] != 'active_record' do
  let(:application) { Application.create }
  let(:user) { User.create(username: 'test', password: '123123') }
  let(:access_token) { AccessToken.create(client: application, resource_owner: user) }

  let(:token) { SecureRandom.hex(16) }

  describe 'validations' do
    it 'validate token uniqueness' do
      another_token = AccessToken.create(client: application)
      token = AccessToken.new(client: application, token: another_token.token)

      expect(token).not_to be_valid
      expect(token.errors.messages).to include(:token)
    end
  end

  describe '#to_bearer_token' do
    context 'config with refresh token' do
      before do
        GrapeOAuth2.config.issue_refresh_token = true
      end

      after do
        GrapeOAuth2.config.issue_refresh_token = false
      end

      it 'returns refresh token' do
        expect(access_token.to_bearer_token[:access_token]).not_to be_blank
      end
    end

    context 'config without refresh token' do
      before do
        GrapeOAuth2.configure do |config|
          config.issue_refresh_token = false
        end
      end

      it 'returns blank refresh token' do
        expect(access_token.to_bearer_token[:refresh_token]).to be_blank
      end
    end
  end

  describe '#authenticate' do
    it 'returns an instance if authenticated successfully' do
      access_token.token = token
      access_token.save

      expect(AccessToken.authenticate(token)).to eq(access_token)
    end

    it 'returns nil if authentication failed' do
      access_token.token = token
      access_token.save

      expect(AccessToken.authenticate("invalid-#{token}")).to be_nil
    end

    it 'returns an instance by refresh token' do
      refresh_token = SecureRandom.hex(6)
      token = AccessToken.create(client: application, refresh_token: refresh_token)

      expect(AccessToken.authenticate(refresh_token, type: :refresh_token)).to eq(token)
      expect(AccessToken.authenticate(refresh_token, type: 'refresh_token')).to eq(token)
    end
  end

  describe '#create_for?' do
    it 'creates a record only for Client' do
      token = AccessToken.create_for(application, nil)

      expect(token.client).not_to be_nil
      expect(token.resource_owner).to be_nil
    end

    it 'creates a record for Client and Resource Owner' do
      token = AccessToken.create_for(application, user)

      expect(token.client).to eq(application)
      expect(token.resource_owner).to eq(user)
    end

    it 'creates a record with scopes' do
      scopes = 'write read'
      token = AccessToken.create_for(application, user, scopes)

      expect(token.client).to eq(application)
      expect(token.resource_owner).to eq(user)
      expect(token.scopes).to eq(scopes)
    end
  end

  describe '#expired?' do
    it 'return false if expires_at nil' do
      access_token.update_column(:expires_at, nil)

      expect(access_token.expired?).to be_falsey
    end

    it 'return false if expires_at < Time.now' do
      expect(access_token.expired?).to be_falsey
    end

    it 'return false if expires_at > Time.now' do
      expired_at = Time.now.utc - GrapeOAuth2.config.token_lifetime + 1
      access_token.update_column(:expires_at, expired_at)

      expect(access_token.expired?).to be_truthy
    end
  end

  describe '#revoked?' do
    it 'return false if revoked_at nil' do
      access_token.update_column(:revoked_at, nil)

      expect(access_token.revoked?).to be_falsey
    end

    it 'return false if revoked_at present' do
      access_token.update_column(:revoked_at, Time.now.utc)
      expect(access_token.revoked?).to be_truthy
    end
  end

  describe '#revoke!' do
    it 'update :revoked_at attribute' do
      expect { access_token.revoke! }.to change { access_token.revoked? }.from(false).to(true)
    end

    it 'update :revoked_at attribute with custom value' do
      custom_time = Time.now - 7200
      access_token.revoke!(custom_time)

      expect(access_token.revoked_at).to eq(custom_time.utc)
    end
  end
end
