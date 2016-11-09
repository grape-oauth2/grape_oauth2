require 'spec_helper'

describe 'GET Protected Resources' do
  let(:application) { Application.create(name: 'App1') }
  let(:user) { User.create(username: 'Jack Sparrow', password: '12345678') }
  let(:access_token) { AccessToken.create_for(application, user) }

  context 'with invalid data' do
    it 'returns Unauthorized without Access Token' do
      get 'api/v1/status'

      expect(last_response.status).to eq 401

      expect(json_body[:error]).to eq('unauthorized')
      expect(last_response.headers['WWW-Authenticate']).to eq('Bearer realm="Custom Realm"')
    end

    it 'returns Unauthorized when token scopes are blank' do
      get 'api/v1/status/single_scope', access_token: access_token.token

      expect(last_response.status).to eq 403

      expect(json_body[:error]).not_to be_blank
    end

    it "returns Unauthorized when token scopes doesn't match required scopes" do
      access_token.update(scopes: 'read')
      get 'api/v1/status/multiple_scopes', access_token: access_token.token

      expect(last_response.status).to eq 403

      expect(json_body[:error]).not_to be_blank
    end
  end

  context 'with valid data' do
    it "returns status for endpoint that doesn't requires any scope" do
      get 'api/v1/status', access_token: access_token.token

      expect(last_response.status).to eq 200

      expect(json_body[:value]).to eq('Nice day!')
      expect(json_body[:current_user]).to eq('Jack Sparrow')
    end

    it 'returns status for endpoint with specific scope' do
      access_token.update(scopes: 'read public')
      get 'api/v1/status/single_scope', access_token: access_token.token

      expect(last_response.status).to eq 200

      expect(json_body[:value]).to eq('Access granted')
    end

    it 'returns status for endpoint with specific set of scopes' do
      access_token.update(scopes: 'read write public')
      get 'api/v1/status/multiple_scopes', access_token: access_token.token

      expect(last_response.status).to eq 200

      expect(json_body[:value]).to eq('Access granted')
    end
  end
end
