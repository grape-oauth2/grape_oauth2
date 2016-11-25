class User < ApplicationRecord
  set_dataset :users
  plugin :secure_password, include_validations: false

  def self.oauth_authenticate(_client, username, password)
    user = find(username: username)
    return if user.nil?

    user.authenticate(password)
  end
end
