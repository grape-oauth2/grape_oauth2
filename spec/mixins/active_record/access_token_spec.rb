require 'spec_helper'

describe 'GrapeOAuth2::ActiveRecord::AccessToken', skip_if: ENV['ORM'] != 'active_record' do
  let(:application) { Application.create }
  let(:user) { User.create(username: 'test', password: '123123') }
  let(:access_token) { AccessToken.create(client: application, resource_owner: user) }

  let(:token) { SecureRandom.hex(16) }

  describe '#to_bearer_token' do
    context 'config with refresh token' do
      before do
        GrapeOAuth2.config.issue_refresh_token = true
      end

      after do
        GrapeOAuth2.config.issue_refresh_token = false
      end

      it 'returns refresh token' do
        expect(access_token.to_bearer_token.access_token).not_to be_blank
      end
    end

    context 'config without refresh token' do
      before do
        GrapeOAuth2.configure do |config|
          config.issue_refresh_token = false
        end
      end

      it 'returns blank refresh token' do
        expect(access_token.to_bearer_token.refresh_token).to be_blank
      end
    end
  end

  describe '#authenticate' do
    it 'returns a class instance if authenticated successfully' do
      access_token.token = token
      access_token.save

      expect(AccessToken.authenticate(token)).to eq(access_token)
    end

    it 'returns nil if authentication failed' do
      access_token.token = token
      access_token.save

      expect(AccessToken.authenticate("invalid-#{token}")).to be_nil
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
end
