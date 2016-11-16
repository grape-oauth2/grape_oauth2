require 'spec_helper'

describe 'GET /oauth/authorize' do
  describe 'Authorization Code flow' do
    let(:authorize_url) { '/api/v1/oauth/authorize' }
    let(:redirect_uri) { 'http://localhost:3000/home' }
    let(:application) { Application.create(name: 'App1', redirect_uri: redirect_uri) }

    context 'with valid params' do
      context 'when response_type is :code' do
        it 'should be success' do
          expect {
            post authorize_url,
              client_id: application.key,
              redirect_uri: redirect_uri,
              response_type: 'code'
          }.to change { AccessCode.count }.from(0).to(1)
        end
      end

      context 'when response_type is :token' do
        it 'should be success' do
          expect {
            post authorize_url,
              client_id: application.key,
              redirect_uri: redirect_uri,
              response_type: 'token'
          }.to change { AccessToken.count }.from(0).to(1)
        end
      end
    end

    context 'with invalid params' do
      it 'should fail without response_type' do
        post authorize_url,
             client_id: application.key

        expect(last_response.status).to eq 400
        # expect(json_body[:error]).to eq('invalid_request')
      end

      it 'should fail with unsupported response_type' do
        post authorize_url,
             client_id: application.key,
             redirect_uri: redirect_uri,
             response_type: 'invalid'

        expect(last_response.status).to eq 400
        # expect(json_body[:error]).to eq('invalid_request')
      end
    end
  end
end
