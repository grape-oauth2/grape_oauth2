DB.create_table :applications do
  primary_key :id

  column :name, String, size: 255, null: false
  column :key, String, size: 255, null: false, index: { unique: true }
  column :secret, String, size: 255, null: false


  column :redirect_uri, String

  column :created_at, DateTime
  column :updated_at, DateTime
end

DB.create_table :access_tokens do
  primary_key :id
  column :client_id, Integer
  column :resource_owner_id, Integer, index: true

  column :token, String, size: 255, null: false, index: { unique: true }

  column :refresh_token, String, size: 255, index: { unique: true }

  column :expires_at, DateTime
  column :revoked_at, DateTime
  column :created_at, DateTime, null: false
  column :scopes, String, size: 255
end

DB.create_table :users do
  primary_key :id
  column :name, String, size: 255
  column :username, String, size: 255
  column :created_at, DateTime
  column :updated_at, DateTime
  column :password_digest, String, size: 255
end
