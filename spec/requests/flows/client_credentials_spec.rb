require 'spec_helper'

describe 'Token Endpoint' do
  describe 'POST /oauth/token' do
    describe 'Client Credentials flow' do
      context 'with valid params' do
        let(:authentication_url) { '/api/v1/oauth/token' }
        let(:application) { Application.create(name: 'App1') }
        let(:user) { User.create(username: 'test', password: '12345678') }

        context 'when request is invalid' do
          it 'fails without Grant Type' do
            post authentication_url,
                 client_id: application.key,
                 client_secret: application.secret

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('invalid_request')
            expect(last_response.status).to eq 400
          end

          it 'fails with invalid Grant Type' do
            post authentication_url,
                 grant_type: 'invalid'

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('unsupported_grant_type')
            expect(last_response.status).to eq 400
          end

          it 'fails without Client Credentials' do
            post authentication_url,
                 grant_type: 'client_credentials'

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('invalid_request')
            expect(last_response.status).to eq 400
          end

          it 'fails with invalid Client Credentials' do
            post authentication_url,
                 grant_type: 'client_credentials',
                 client_id: 'blah-blah',
                 client_secret: application.secret

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('invalid_client')
            expect(last_response.status).to eq 401
          end
        end

        context 'with valid data' do
          context 'when scopes requested' do
            it 'returns an Access Token with scopes' do
              post authentication_url,
                   grant_type: 'client_credentials',
                   scope: 'read write',
                   client_id: application.key,
                   client_secret: application.secret

              expect(AccessToken.count).to eq 1
              expect(AccessToken.first.client_id).to eq application.id

              expect(json_body[:access_token]).to be_present
              expect(json_body[:token_type]).to eq 'bearer'
              expect(json_body[:expires_in]).to eq 7200
              expect(json_body[:refresh_token]).to be_nil
              expect(json_body[:scope]).to eq('read write')

              expect(last_response.status).to eq 200
            end
          end

          context 'without scopes' do
            it 'returns an Access Token without scopes' do
              post authentication_url,
                   grant_type: 'client_credentials',
                   client_id: application.key,
                   client_secret: application.secret

              expect(AccessToken.count).to eq 1
              expect(AccessToken.first.client_id).to eq application.id

              expect(json_body[:access_token]).to be_present
              expect(json_body[:token_type]).to eq 'bearer'
              expect(json_body[:expires_in]).to eq 7200
              expect(json_body[:refresh_token]).to be_nil
              expect(json_body[:scope]).to be_nil

              expect(last_response.status).to eq 200
            end
          end
        end
      end
    end
  end
end
