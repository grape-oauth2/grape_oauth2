require 'spec_helper'

describe 'Authentication' do
  describe 'POST /oauth/token' do
    describe 'Resource Owner Password Credentials flow' do
      context 'with valid params' do
        let(:authentication_url) { '/api/oauth/token' }
        let(:application) { create(:application) }
        let(:user) { create :user, username: 'test', password: '12345678' }

        context 'when request is invalid' do
          it 'fails with invalid Grant Type' do
            post authentication_url,
                 grant_type: 'invalid',
                 username: user.username,
                 password: '12345678'

            expect(AccessToken.all).to be_empty

            expect(json['error']).to eq('unsupported_grant_type')
            expect(response).not_to be_success
          end

          it 'fails without Client Credentials' do
            post authentication_url,
                 grant_type: 'password',
                 username: user.username,
                 password: '12345678'

            expect(AccessToken.all).to be_empty

            expect(json['error']).to eq('invalid_request')
            expect(response).not_to be_success
          end

          it 'fails with invalid Client Credentials' do
            post authentication_url,
                 grant_type: 'password',
                 username: user.username,
                 password: '12345678',
                 client_id: 'blah-blah',
                 client_secret: application.secret

            expect(AccessToken.all).to be_empty

            expect(json['error']).to eq('invalid_client')
            expect(response).not_to be_success
          end

          it 'fails with invalid Resource Owner credentials' do
            post authentication_url,
                 grant_type: 'password',
                 username: 'invalid@example.com',
                 password: 'invalid',
                 client_id: application.key,
                 client_secret: application.secret

            expect(json['error']).to eq('invalid_grant')
            expect(json['error_description']).not_to be_blank
            expect(response.status).to eq 400
          end
        end

        context 'with valid data' do
          it 'returns access token' do
            post authentication_url,
                 grant_type: 'password',
                 username: user.username,
                 password: '12345678',
                 client_id: application.key,
                 client_secret: application.secret

            expect(AccessToken.count).to eq 1
            expect(AccessToken.first.application_id).to eq application.id

            expect(json['access_token']).to be_present
            expect(json['token_type']).to eq 'bearer'
            expect(json['expires_in']).to eq 7200

            expect(response.status).to eq 200
          end
        end
      end
    end
  end
end
