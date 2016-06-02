require 'spec_helper'

describe 'Token Endpoint' do
  describe 'POST /oauth/token' do
    describe 'Resource Owner Password Credentials flow' do
      context 'with valid params' do
        let(:authentication_url) { '/api/v1/oauth/token' }
        let(:application) { Application.create(name: 'App1') }
        let(:user) { User.create(username: 'test', password: '12345678') }

        context 'when request is invalid' do
          it 'fails with invalid Grant Type' do
            post authentication_url,
                 grant_type: 'invalid',
                 username: user.username,
                 password: '12345678'

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('unsupported_grant_type')
            expect(last_response.status).to eq 400
          end

          it 'fails without Client Credentials' do
            post authentication_url,
                 grant_type: 'password',
                 username: user.username,
                 password: '12345678'

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('invalid_request')
            expect(last_response.status).to eq 400
          end

          it 'fails with invalid Client Credentials' do
            post authentication_url,
                 grant_type: 'password',
                 username: user.username,
                 password: '12345678',
                 client_id: 'blah-blah',
                 client_secret: application.secret

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('invalid_client')
            expect(last_response.status).to eq 401
          end

          it 'fails with invalid Resource Owner credentials' do
            post authentication_url,
                 grant_type: 'password',
                 username: 'invalid@example.com',
                 password: 'invalid',
                 client_id: application.key,
                 client_secret: application.secret

            expect(json_body[:error]).to eq('invalid_grant')
            expect(json_body[:error_description]).not_to be_blank
            expect(last_response.status).to eq 400
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
            expect(AccessToken.first.client_id).to eq application.id

            expect(json_body[:access_token]).to be_present
            expect(json_body[:token_type]).to eq 'bearer'
            expect(json_body[:expires_in]).to eq 7200

            expect(last_response.status).to eq 200
          end
        end
      end
    end
  end
end
