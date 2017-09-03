require 'spec_helper'

describe 'Grape::OAuth2::ActiveRecord::Client', skip_if: ENV['ORM'] != 'active_record' do
  let(:client) { Application.new }

  let(:key) { SecureRandom.hex(8)  }
  let(:secret) { SecureRandom.hex(8) }

  it 'generates key on create' do
    expect(client.key).to be_nil
    client.save
    expect(client.key).not_to be_nil
  end

  it 'generates key on create if an empty string' do
    client.key = ''
    client.save
    expect(client.key).not_to be_blank
  end

  it 'generates key on create unless one is set' do
    client.key = key
    client.save
    expect(client.key).to eq(key)
  end

  it 'is invalid without key' do
    client.save
    client.key = nil
    expect(client).not_to be_valid
  end

  it 'checks uniqueness of key' do
    app1 = Application.create
    app2 = Application.create
    app2.key = app1.key
    expect(app2).not_to be_valid
  end

  it 'expects database to throw an error when keys are the same' do
    app1 = Application.create
    app2 = Application.create
    app2.key = app1.key
    expect { app2.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'generate secret on create' do
    expect(client.secret).to be_nil
    client.save
    expect(client.secret).not_to be_nil
  end

  it 'generate secret on create if is blank string' do
    client.secret = ''
    client.save
    expect(client.secret).not_to be_blank
  end

  it 'generate secret on create unless one is set' do
    client.secret = secret
    client.save
    expect(client.secret).to eq(secret)
  end

  it 'is invalid without secret' do
    client.save
    client.secret = nil
    expect(client).not_to be_valid
  end

  describe '#authenticate' do
    it 'returns a class instance if authenticated successfully' do
      client.key = key
      client.secret = secret
      client.save

      expect(Application.authenticate(key, secret)).to eq(client)
    end

    it 'returns a class instance if only key specified' do
      client.key = key
      client.save

      expect(Application.authenticate(key)).to eq(client)
    end

    it 'returns nil if authentication failed' do
      client.key = key
      client.secret = secret
      client.save

      expect(Application.authenticate(key, 'invalid-')).to be_nil
    end

    it 'delete all the associated access tokens on destroy' do
      user = User.create!(name: 'John', password: '123123')
      app = Application.create!(name: 'app1', redirect_uri: 'https://google.com')

      3.times { AccessToken.create(resource_ownder_id: user.id, client_id: app.id) }

      expect { app.reload.destroy }.to change { app.reload.access_tokens.count }.from(3).to(0)
    end
  end
end
