require 'spec_helper'

describe 'GET /oauth/authorize' do
  describe 'Authorization Code flow' do
    let(:authorize_url) { '/api/v1/oauth/authorize' }
    let(:application) { Application.create(name: 'App1') }

    context 'with valid params' do
      xit 'should be success' do
      end
    end

    context 'with invalid params' do
      xit 'should fail without response_type' do
        get authorize_url,
            client_id: application.key,
            redirect_uri: 'https://google.com'

        expect(last_response.status).to eq 400
        expect(json_body[:error]).to eq('invalid_request')
      end
    end
  end
end
