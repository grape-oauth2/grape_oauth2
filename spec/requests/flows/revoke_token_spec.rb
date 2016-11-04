require 'spec_helper'

describe 'Token Endpoint' do
  describe 'POST /oauth/revoke' do
    describe 'Revoke Token' do
      context 'with valid params' do
        let(:api_url) { '/api/v1/oauth/revoke' }
        let(:application) { Application.create(name: 'App1') }
        let(:user) { User.create(username: 'test', password: '12345678') }

        describe 'for public' do
          context 'when request is invalid' do
            before { AccessToken.create_for(application, user)  }

            it 'do nothing' do
              expect {
                post api_url, token: 'invalid token'
              }.not_to change { AccessToken.active.count }

              expect(json_body).to eq({})
              expect(last_response.status).to eq 200

              expect(AccessToken.last).not_to be_revoked
            end
          end

          context 'with valid data' do
            before { AccessToken.create_for(application, user)  }

            it 'revokes Access Token by its token' do
              expect {
                post api_url, token: AccessToken.last.token
              }.to change { AccessToken.active.count }.from(1).to(0)

              expect(json_body).to eq({})
              expect(last_response.status).to eq 200

              expect(AccessToken.last).to be_revoked
              expect(AccessToken.last).not_to be_accessible
            end

            it 'revokes Access Token by its refresh token' do
              refresh_token = SecureRandom.hex(16)
              AccessToken.last.update_column(:refresh_token, refresh_token)

              expect {
                post api_url, token: refresh_token, token_type_hint: 'refresh_token'
              }.to change { AccessToken.active.count }.from(1).to(0)

              expect(json_body).to eq({})
              expect(last_response.status).to eq 200

              expect(AccessToken.last).to be_revoked
              expect(AccessToken.last).not_to be_accessible
            end
          end
        end

        xdescribe 'for private' do
          it 'revokes token with client authorization' do
          end
        end
      end
    end
  end
end
