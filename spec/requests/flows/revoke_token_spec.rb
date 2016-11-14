require 'spec_helper'

describe 'Token Endpoint' do
  describe 'POST /oauth/revoke' do
    describe 'Revoke Token flow' do
      context 'with valid params' do
        let(:api_url) { '/api/v1/oauth/revoke' }
        let(:application) { Application.create(name: 'App1') }
        let(:user) { User.create(username: 'test', password: '12345678') }

        let(:headers) { { 'HTTP_AUTHORIZATION' => ('Basic ' + Base64::encode64("#{application.key}:#{application.secret}")) } }

        describe 'for public token' do
          context 'when request is invalid' do
            before { AccessToken.create_for(application, user)  }

            it 'does nothing' do
              expect {
                post api_url, { token: 'invalid token' }, headers
              }.not_to change { AccessToken.count }

              expect(json_body).to eq({})
              expect(last_response.status).to eq 200

              expect(AccessToken.last).not_to be_revoked
            end

            it 'returns an error with invalid token_type_hint' do
              expect {
                post api_url, { token: AccessToken.last.token, token_type_hint: 'undefined' }, headers
              }.not_to change { AccessToken.count }

              expect(last_response.status).to eq 400
            end
          end

          context 'with valid data' do
            before { AccessToken.create_for(application, user)  }

            it 'revokes Access Token by its token' do
              expect {
                post api_url, { token: AccessToken.last.token }, headers
              }.to change { AccessToken.where(revoked_at: nil).count }.from(1).to(0)

              expect(json_body).to eq({})
              expect(last_response.status).to eq 200

              expect(AccessToken.last).to be_revoked
            end

            it 'revokes Access Token by its refresh token' do
              refresh_token = SecureRandom.hex(16)
              AccessToken.last.update(refresh_token: refresh_token)

              expect {
                post api_url, { token: refresh_token, token_type_hint: 'refresh_token' }, headers
              }.to change { AccessToken.where(revoked_at: nil).count }.from(1).to(0)

              expect(json_body).to eq({})
              expect(last_response.status).to eq 200

              expect(AccessToken.last).to be_revoked
            end
          end
        end

        describe 'for private token' do
          before { AccessToken.create_for(application, user)  }

          context 'with valid data' do
            it 'revokes token with client authorization' do
              expect {
                post api_url, { token: AccessToken.last.token}, headers
              }.to change { AccessToken.where(revoked_at: nil).count }.from(1).to(0)
            end
          end

          context 'with invalid data' do
            it 'does not revokes Access Token when credentials is invalid' do
              expect {
                post api_url, token: AccessToken.last.token
              }.to_not change { AccessToken.where(revoked_at: nil).count }

              expect(json_body[:error]).to eq('invalid_client')
            end

            it 'does not revokes Access Token when token was issued to another client' do
              another_client = Application.create(name: 'Some')
              AccessToken.last.update(client_id: another_client.id)

              expect {
                post api_url, token: AccessToken.last.token
              }.to_not change { AccessToken.where(revoked_at: nil).count }

              expect(json_body[:error]).to eq('invalid_client')
            end
          end
        end
      end
    end
  end
end
