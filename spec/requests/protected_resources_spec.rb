require 'spec_helper'

describe 'Protected Resources' do
  describe 'GET /api/v1/status' do
    context 'with valid params' do
      let(:application) { Application.create(name: 'App1') }
      let(:user) { User.create(username: 'test', password: '12345678') }
      let(:access_token) { AccessToken.create_for(application, user) }

      context 'without Access Token' do
        it 'returns Unauthorized' do
          get 'api/v1/status'

          expect(last_response.status).to eq 401
          expect(json_body[:error]).to eq('unauthorized')
        end
      end

      context 'with Access Token' do
        it 'returns status' do
          get 'api/v1/status', access_token: access_token.token

          expect(last_response.status).to eq 200
          # expect(json_body[:name]).to eq('test')
        end
      end
    end
  end
end
