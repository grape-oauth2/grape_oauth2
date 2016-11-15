require 'spec_helper'

describe 'GET /oauth/authorize' do
  describe 'Authorization Code flow' do
    let(:authorize_url) { '/api/v1/oauth/authorize' }
    let(:redirect_uri) { 'http://localhost:3000/home' }
    let(:application) { Application.create(name: 'App1', redirect_uri: redirect_uri) }

    context 'with valid params' do
      it 'should be success' do
        expect {
          post authorize_url,
            client_id: application.key,
            redirect_uri: redirect_uri,
            response_type: 'code'
        }.to change { AccessCode.count }.from(0).to(1)
      end
    end

    context 'with invalid params' do
    end
  end
end
