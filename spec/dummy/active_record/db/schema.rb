ActiveRecord::Schema.define(version: 3) do
  create_table :users do |t|
    t.string :name
    t.string :username
    t.string :password_digest
  end

  create_table :applications do |t|
    t.string :name
    t.string :key
    t.string :secret
    t.string :redirect_uri

    t.timestamps null: false
  end

  add_index :applications, :key, unique: true

  create_table :access_tokens do |t|
    t.integer :resource_owner_id
    t.integer :client_id

    t.string :token, null: false
    t.string :refresh_token
    t.string :scopes

    t.datetime :expires_at
    t.datetime :revoked_at
    t.datetime :created_at, null: false
  end

  create_table :access_codes do |t|
    t.integer :resource_owner_id
    t.integer :client_id

    t.string :token, null: false
    t.string :redirect_uri
    t.string :scopes

    t.datetime :expires_at
    t.datetime :revoked_at
    t.datetime :created_at, null: false
  end

  add_index :access_tokens, :token, unique: true
  add_index :access_tokens, :resource_owner_id
  add_index :access_tokens, :client_id
  add_index :access_tokens, :refresh_token, unique: true

  add_index :access_codes, :token, unique: true
  add_index :access_codes, :resource_owner_id
  add_index :access_codes, :client_id
end
