require 'spec_helper'

describe 'Authorization Code flow' do
  let(:redirect_uri) { 'http://localhost:3000/home' }
  let(:application) { Application.create(name: 'App1', redirect_uri: redirect_uri) }

  describe 'POST /oauth/authorize' do
    let(:authorize_url) { '/api/v1/oauth/authorize' }

    context 'with valid params' do
      context 'when response_type is :code' do
        it 'should be success' do
          expect {
            post authorize_url,
              client_id: application.key,
              redirect_uri: redirect_uri,
              response_type: 'code'
          }.to change { AccessCode.count }.from(0).to(1)

          expect(last_response.status).to eq 302
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
        expect(json_body[:error]).to eq('invalid_request')
      end

      it 'should fail with unsupported response_type' do
        post authorize_url,
             client_id: application.key,
             redirect_uri: redirect_uri,
             response_type: 'invalid'

        expect(last_response.status).to eq 400
        expect(json_body[:error]).to eq('unsupported_response_type')
      end
    end
  end

  describe 'POST /oauth/custom_authorize' do
    it 'invokes custom block' do
      post '/api/v1/oauth/custom_authorize',
           client_id: application.key,
           redirect_uri: redirect_uri,
           response_type: 'code'

      expect(last_response.status).to eq(400)
    end
  end
end
