require 'spec_helper'

describe 'Token Endpoint' do
  describe 'POST /oauth/token' do
    describe 'Refresh Token flow' do
      context 'with valid params' do
        let(:api_url) { '/api/v1/oauth/token' }
        let(:application) { Application.create(name: 'App1') }
        let(:user) { User.create(username: 'test', password: '12345678') }

        context 'when request is invalid' do
          it 'fails without Grant Type' do
            post api_url,
                 client_id: application.key,
                 client_secret: application.secret

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('invalid_request')
            expect(last_response.status).to eq 400
          end

          it 'fails with invalid Grant Type' do
            post api_url,
                 grant_type: 'invalid'

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('unsupported_grant_type')
            expect(last_response.status).to eq 400
          end

          it 'fails without Client Credentials' do
            post api_url,
                 grant_type: 'refresh_token'

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('invalid_request')
            expect(last_response.status).to eq 400
          end

          it 'fails with invalid Client Credentials' do
            post api_url,
                 grant_type: 'refresh_token',
                 refresh_token: SecureRandom.hex(6),
                 client_id: 'blah-blah',
                 client_secret: application.secret

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('invalid_client')
            expect(last_response.status).to eq 401
          end

          it 'fails when Access Token was issued to another client' do
            allow(GrapeOAuth2.config).to receive(:issue_refresh_token).and_return(true)

            another_client = Application.create(name: 'Some')
            token = AccessToken.create_for(another_client, user)
            expect(token.refresh_token).not_to be_nil

            post api_url,
                 grant_type: 'refresh_token',
                 refresh_token: token.refresh_token,
                 client_id: application.key,
                 client_secret: application.secret

            expect(json_body[:error]).to eq('unauthorized_client')
            expect(last_response.status).to eq 400

            expect(AccessToken.count).to eq(1)
          end
        end

        context 'with valid data' do
          before { allow(GrapeOAuth2.config).to receive(:issue_refresh_token).and_return(true) }

          it 'returns a new Access Token' do
            token = AccessToken.create_for(application, user)
            expect(token.refresh_token).not_to be_nil

            post api_url,
                 grant_type: 'refresh_token',
                 refresh_token: token.refresh_token,
                 client_id: application.key,
                 client_secret: application.secret

            expect(last_response.status).to eq 200

            expect(AccessToken.count).to eq 2
            expect(AccessToken.last.client_id).to eq application.id
            expect(AccessToken.last.resource_owner_id).to eq user.id

            expect(json_body[:access_token]).to eq AccessToken.last.token
            expect(json_body[:token_type]).to eq 'bearer'
            expect(json_body[:expires_in]).to eq 7200
            expect(json_body[:refresh_token]).to eq AccessToken.last.refresh_token
          end

          it 'rrevokes old Access Token if configured' do
            allow(GrapeOAuth2.config).to receive(:revoke_after_refresh).and_return(true)

            token = AccessToken.create_for(application, user)
            expect(token.refresh_token).not_to be_nil

            post api_url,
                 grant_type: 'refresh_token',
                 refresh_token: token.refresh_token,
                 client_id: application.key,
                 client_secret: application.secret

            expect(last_response.status).to eq 200

            expect(AccessToken.count).to eq 2
            expect(AccessToken.last.client_id).to eq application.id
            expect(AccessToken.last.resource_owner_id).to eq user.id

            expect(token.reload.revoked?).to be_truthy
            expect(token.reload).not_to be_accessible

            expect(json_body[:access_token]).to eq AccessToken.last.token
            expect(json_body[:refresh_token]).to eq AccessToken.last.refresh_token
          end

          it 'returns a new Access Token even if used token is expired' do
            token = AccessToken.create_for(application, user)
            token.update(expires_at: Time.now - 604800) # - 7 days
            expect(token.refresh_token).not_to be_nil

            post api_url,
                 grant_type: 'refresh_token',
                 refresh_token: token.refresh_token,
                 client_id: application.key,
                 client_secret: application.secret

            expect(last_response.status).to eq 200

            expect(AccessToken.count).to eq 2
            expect(AccessToken.last.client_id).to eq application.id
            expect(AccessToken.last.resource_owner_id).to eq user.id

            expect(json_body[:access_token]).to eq AccessToken.last.token
            expect(json_body[:token_type]).to eq 'bearer'
            expect(json_body[:expires_in]).to eq 7200
            expect(json_body[:refresh_token]).to eq AccessToken.last.refresh_token
          end
        end
      end
    end
  end
end
